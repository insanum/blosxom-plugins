# Blosxom Plugin: tasks
# Author(s): Eric Davis <edavis <at> foobargeek <dot> com>
# Documentation: See the bottom of this file or type: perldoc tasks

package Blosxom::Plugin::Tasks;

# --- Configurable variables ---

# the file containing the list of tasks and percentage done
my $cachefile = "tasks.txt";

# the character to use in the percentage complete gant chart (note that this
# could be a link to link to an image which represents a unit in a bar graph)
my $tasks_graph_char = "-";

# The maximum width (in characters) the percentage complete gant chart can
# consume
my $tasks_max_graph_length = 46;

# require a password to be submitted when administrating tasks
# entries (0 = no, 1 = yes)
my $require_password = 1;

# the password that allows administration of tasks
my $password = "foobar";

# allow administration only from a select set of IP addresses
# (0 = no, 1 = yes)
$restrict_admin_by_ip = 0;

# what IP addreses have administration access
@admin_ip_addrs = qw/ 127.0.0.1 /;

# ------------------------------

use CGI qw/:standard/;

$display; # $Plugin::Tasks::display
$admin;   # $Plugin::Tasks::admin

sub TasksAdmin
{
    my ($blosxom) = @_;
    my $admin_password = param('password');
    my $num_removed = 0;
    my $num_descr_modified = 0;
    my $num_perc_modified = 0;
    my $num_added = 0;
    my $task_descr = '';
    my $task_perc = '';
    my @task_descriptions;
    my @task_percentages;
    my $realCachefile = "$blosxom->{settings}->{state_dir}/$cachefile";

    if ($require_password && ($password ne $admin_password))
    {
        $admin .= qq{<div class="tasks_admin_response">Invalid Password!</div>\n};
        TasksAdminDisplay($blosxom);
        return;
    }

    # open the $realCachefile for reading/writing(append) and create if doesn't exist
    open(TASKS, "+>>$realCachefile");
    flock(TASKS, LOCK_EX);

    seek(TASKS, 0, 0); # seek to the beginning of the cache file

    while (<TASKS>)
    {
        next if ($line =~ /^\s$/); # skip emtpy lines

        if (/^-----$/)
        {
            push(@task_descriptions, $task_descr);
            push(@task_percentages, $task_perc);

            $task_descr = '';
            $task_perc = '';

            next;
        }

        # task name
        if (/^task:\s*(.*)\s*$/)
        {
            $task_descr = $1;
        }
        # percentage complete
        elsif (/^complete:\s*(.*)\s*$/)
        {
            $task_perc = $1;
        }
    }

    foreach (param)
    {
        if (/^(\d+)_remove$/) # [index]_remove param
        {
            $task_descriptions[$1] = '';
            $task_percentages[$1] = '';
            $num_removed++;
        }

        if (/^(\d+)_descr$/) # [index]_descr param
        {
            $task_descriptions[$1] = param($_) and $num_descr_modified++ if ($task_descriptions[$1] ne '' and param($_) ne $task_descriptions[$1]);
        }

        if (/^(\d+)_percentage$/) # [index]_percentage param
        {
            $task_percentages[$1] = param($_) and $num_perc_modified++ if ($task_percentages[$1] ne '' and param($_) ne $task_percentages[$1]);
        }

        if (/^new_descr$/) # new_descr param
        {
            my $descr = param('new_descr');

            if ($descr ne '')
            {
                my $perc = param('new_percentage');

                push(@task_descriptions, $descr);

                if ($perc ne '')
                {
                    push(@task_percentages, $perc);
                }
                else
                {
                    push(@task_percentages, '0');
                }

                $num_added++
            }
        }
    }

    if ($num_removed == 0 && $num_descr_modified == 0 && $num_perc_modified == 0 && $num_added == 0)
    {
        $admin .= qq{<div class="tasks_admin_response">Nothing changed.</div>\n};
    }
    else
    {
        truncate(TASKS, 0); # truncate the existing file

        for (my $i = 0; $i <= $#task_descriptions; $i++)
        {
            if ($task_descriptions[$i] ne '')
            {
                print(TASKS "task: $task_descriptions[$i]\n");
                print(TASKS "complete: $task_percentages[$i]\n");
                print(TASKS "-----\n");
            }
        }

        $admin .= qq{<div class="tasks_admin_response">Number of tasks removed: $num_removed</div>\n} if ($num_removed != 0);
        $admin .= qq{<div class="tasks_admin_response">Number of task descriptions modified: $num_descr_modified</div>\n} if ($num_descr_modified != 0);
        $admin .= qq{<div class="tasks_admin_response">Number of task percentages modified: $num_perc_modified</div>\n} if ($num_perc_modified != 0);
        $admin .= qq{<div class="tasks_admin_response">New task entered.</div>\n} if ($num_added != 0);
    }

    flock(TASKS, LOCK_UN);
    close(TASKS);

    TasksAdminDisplay($blosxom);
}


sub TasksAdminDisplay
{
    my ($blosxom) = @_;
    my $task_descr = '';
    my $task_perc = '';
    my $count = 0;
    my $realCachefile = "$blosxom->{settings}->{state_dir}/$cachefile";

    # check administration IP address if restriction is turned on
    if ($restrict_admin_by_ip and !grep(/^\Q$ENV{'REMOTE_ADDR'}\E$/, @admin_ip_addrs))
    {
        $admin .= qq{<div class="tasks_admin_response">Access denied from $ENV{'REMOTE_ADDR'}!</div>\n};
        $blosxom->{state}->{Plugin}->{Tasks}->{admin} = $admin;
        return;
    }

    $admin .= qq{<div class="tasks_admin">\n};
    $admin .= qq{<form class="tasks_admin_form" method="POST" action="$blosxom->{settings}->{url}/index.tasks">\n};
    $admin .= qq{<table class="tasks_admin_table">\n};

    $admin .= qq{<tr class="tasks_admin_row">\n};
    $admin .= qq{  <td class="tasks_admin_remove_checkbox">\n};
    $admin .= qq{    <b>Remove</b>\n};
    $admin .= qq{  </td>\n};
    $admin .= qq{  <td class="tasks_admin_task_descr">\n};
    $admin .= qq{    <b>Task Description</b>\n};
    $admin .= qq{  </td>\n};
    $admin .= qq{  <td class="tasks_admin_task_percentage">\n};
    $admin .= qq{    <b>% Complete</b>\n};
    $admin .= qq{  </td>\n};
    $admin .= qq{</tr>\n};

    # open the $realCachefile for reading/writing(append) and create if doesn't exist
    open(TASKS, "+>>$realCachefile");
    flock(TASKS, LOCK_EX);

    seek(TASKS, 0, 0); # seek to the beginning of the cache file

    while (<TASKS>)
    {
        next if ($line =~ /^\s$/); # skip emtpy lines

        if (/^-----$/)
        {
            $admin .= qq{<tr class="tasks_admin_row">\n};
            $admin .= qq{  <td class="tasks_admin_remove_checkbox">\n};
            $admin .= qq{    <input type="checkbox" name="${count}_remove" value="1" unchecked />\n};
            $admin .= qq{  </td>\n};
            $admin .= qq{  <td class="tasks_admin_task_descr">\n};
            $admin .= qq{    <input class="tasks_admin_task_descr_field" name="${count}_descr" size="80" value="$task_descr" />\n};
            $admin .= qq{  </td>\n};
            $admin .= qq{  <td class="tasks_admin_task_percentage">\n};
            $admin .= qq{    <input class="tasks_admin_task_percentage_field" name="${count}_percentage" size="3" value="$task_perc" />\n};
            $admin .= qq{  </td>\n};
            $admin .= qq{</tr>\n};

            $count++;
            $task_descr = '';
            $task_perc = '';

            next;
        }

        # task name
        if (/^task:\s*(.*)\s*$/)
        {
            $task_descr = $1;
        }
        # percentage complete
        elsif (/^complete:\s*(.*)\s*$/)
        {
            $task_perc = $1;
        }
    }

    flock(TASKS, LOCK_UN);
    close(TASKS);

    $admin .= qq{<tr class="tasks_admin_row">\n};
    $admin .= qq{  <td class="tasks_admin_remove_checkbox">\n};
    $admin .= qq{    <b>New</b>\n};
    $admin .= qq{  </td>\n};
    $admin .= qq{  <td class="tasks_admin_task_descr">\n};
    $admin .= qq{    <input class="tasks_admin_task_descr_field" name="new_descr" size="80" value="" />\n};
    $admin .= qq{  </td>\n};
    $admin .= qq{  <td class="tasks_admin_task_percentage">\n};
    $admin .= qq{    <input class="tasks_admin_task_percentage_field" name="new_percentage" size="3" value="" />\n};
    $admin .= qq{  </td>\n};
    $admin .= qq{</tr>\n};

    $admin .= qq{</table>\n};

    $admin .= qq{<div class="tasks_admin_submit">\n};
    $admin .= qq{Password: <input class="tasks_admin_password" name="password" size="15" value="" type="password" /><br />\n};
    $admin .= qq{<input type="hidden" name="plugin" value="tasks_admin" />\n};
    $admin .= qq{<input class="tasks_admin_submit_button" type="submit" name="submit" value="Submit" />\n};
    $admin .= qq{</div>\n};

    $admin .= qq{</form>\n};
    $admin .= qq{</div>\n};

    $blosxom->{state}->{Plugin}->{Tasks}->{admin} = $admin;
}


sub TasksDisplay
{
    my ($blosxom) = @_;
    my $realCachefile = "$blosxom->{settings}->{state_dir}/$cachefile";

    $display .= qq{<div class="tasks">\n<table class="tasks_table">\n};

    # open the $realCachefile for reading/writing(append) and create if doesn't exist
    open(TASKS, "+>>$realCachefile");
    flock(TASKS, LOCK_EX);

    seek(TASKS, 0, 0); # seek to the beginning of the cache file

    while (<TASKS>)
    {
        chomp();

        next if (/^$tasks_seperator$/);

        # task name
        if (/^task:\s*(.*)\s*$/)
        {
            $display .= qq{<tr class="tasks_row">\n};
            $display .= qq{<td class="tasks_task">$1</td>\n};
        }
        # percentage complete
        elsif (/^complete:\s*(.*)\s*$/)
        {
            $display .= qq{<td class="tasks_percentage">$1%</td>\n};
            $display .= qq{<td class="tasks_graph">};
            $length = ($tasks_max_graph_length * ($1 / 100));

            for (my $i = 0; $i < $length; $i++)
            {
                $display .= qq{$tasks_graph_char};
            }

            $display .= qq{</td>\n};
            $display .= qq{</tr>\n};
        }
    }

    flock(TASKS, LOCK_UN);
    close(TASKS);

    $display .= qq{</table>\n</div>\n};

    $blosxom->{state}->{Plugin}->{Tasks}->{display} = $display;
}


sub Run
{
    my $blosxom = shift;

    # if POSTing to the tasks 'admin' interface then remove the specified entries
    if (request_method() eq 'POST' and param('plugin') eq 'tasks_admin')
    {
        TasksAdmin($blosxom);
    }

    # else if the the tasks flavour was specified then build the admin table
    elsif ($blosxom->{request}->{flavour} eq 'tasks')
    {
        TasksAdminDisplay($blosxom);
    }

    # else another flavour is being shown so build the tasks table
    else
    {
        TasksDisplay($blosxom);
    }

    return 1;
}

1;

__END__

=head1 NAME

Blosxom Plugin: tasks

=head1 DESCRIPTION

This plug-in provides a B<$Plugin::Tasks::display> variable that shows a table of
tasks and the percentage complete for each task.

B<$cachefile>: the location of the cache file holding all the task information

B<$tasks_graph_char>: the character to use in the percentage complete gant chart
(note that this could be a link to link to an image which represents a unit in
a bar graph)

B<$tasks_max_graph_length>: The maximum width (in characters) the percentage
complete gant chart can consume

The following class identifiers are used for CSS control of the table:

B<tasks>: the task display output as a whole

B<tasks_table>: the task table

B<tasks_row>: a row in the task table

B<tasks_task>: the task description cell in a task row

B<tasks_percentage>: the percentage done cell in a task row

B<tasks_graph>: the percentage graph cell in a task row

This plugin also provides a management interface that allows you to submit new
tasks, remove finished tasks, or modify existing tasks.  A B<$Plugin::Tasks::admin>
variable is provided that contains a form showing all the tasks descriptions
and percentages in text edit boxes, task remove checkboxes, a password field,
and a submit button.  You modify the data how you want, enter that password,
and click the submit button.  The tasks administration interface can be
modified via the following configuration variables:

B<$require_password>: require a password to be submitted when administrating
tasks (0 = no, 1 = yes)

B<$password>: the password that allows administration of the task information

B<$restrict_admin_by_ip>: allow administration only from a select set of IP
addresses (0 = no, 1 = yes)

B<@admin_ip_addrs>: list of IP addreses that have administration access

The following class identifiers are used for CSS control of the task
admin display:

B<tasks_admin>: the task admin output as a whole

B<tasks_admin_response>: the response from a task admin action

B<tasks_admin_form>: the task admin form - check boxes, text fields, and
submit button

B<tasks_admin_table>: the task admin table - check boxes and text fileds

B<tasks_admin_row>: a row in the task admin table

B<tasks_admin_remove_checkbox>: the remove checkbox cell in the row

B<tasks_admin_task_descr>: the task description cell in the row

B<tasks_admin_task_descr_field>: the task description edit box

B<tasks_admin_task_percentage>: the task percentage cell in the row

B<tasks_admin_task_percentage_field>: the task percentage edit box

B<tasks_admin_submit>: the task admin submit button and password entry

B<tasks_admin_password>: the task admin password entry

B<tasks_admin_submit_button>: the task admin submit button

Included with this plugin is a 'tasks' flavour theme.  Drop the file into 
your theme directory, or break it out in the specific flavour files, and then
point your browser to 'index.tasks'.  You will be presented with a task
admin page which you can use to edit previously submitted tasks.  If you
choose not to use this theme, simply use the B<$Plugin::Tasks::admin> variable
anywhere in you existing flavour files to access the task admin interface.

=head1 VERSION

3.1    initial implementation

=head1 VERSION HISTORY

3.1    initial implementation

=head1 AUTHORS

Eric Davis <edavis <at> foobargeek <dot> com> http://www.foobargeek.com

=head1 LICENSE

This source is submitted to the public domain.  Feel free to use and modify it.
If you like, a comment in your modified source attributing credit for my original
work would be appreciated.

THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT ANY WARRANTY OF ANY KIND.  USE AT YOUR OWN RISK!


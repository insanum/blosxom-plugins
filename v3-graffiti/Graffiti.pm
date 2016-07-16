# Blosxom v3 Plugin: graffiti
# Author(s): Eric Davis <edavis <at> foobargeek <dot> com>
# Documentation: See the bottom of this file or type: perldoc graffiti

package Blosxom::Plugin::Graffiti;

# --- Configurable variables -----

# set this to the file name used as the graffiti cache
my $cachefile = "graffiti.dat";

# number of entries to show in the scrollbox (last N entries entered)
my $entries_to_show = 20;

# string separator inserted between entries in the text box
my $entry_separator = "\n";

# size of the text box
my $text_rows = "10";
my $text_cols = "16";

# size of the entry box
my $entry_rows = "2";
my $entry_cols = "16";

# turn on new entry filtering (0 = no, 1 = yes)
my $filter_new_entries = 0;

# a regex string that is used to filter out new entries
# (i.e. normally an 'or' separated list of words)
my $entry_filter = 'bad|words|not|allowed';

# display a response string after a new entry is submitted (0 = no, 1 = yes)
my $display_feedback_string = 1;

# allow new graffiti entries only from a select set of IP addresses
# (0 = no, 1 = yes)
$restrict_new_entry_by_ip = 0;

# what IP addreses have new entry submission access
@new_entry_ip_addrs = qw/ 127.0.0.1 /;

# response string to display when a new entry has been filtered/denied
my $error_string = "Submission Denied";

# response string to display when a new entry has been accepted
my $valid_string = "Thank You";

# require a password to be submitted when administrating graffiti
# entries (0 = no, 1 = yes)
my $require_password = 1;

# the password that allows administration of graffiti entries
my $password = "foobar";

# allow administration only from a select set of IP addresses
# (0 = no, 1 = yes)
$restrict_admin_by_ip = 0;

# what IP addreses have administration access
@admin_ip_addrs = qw/ 127.0.0.1 /;

# --------------------------------

use CGI qw/:standard/;

my $display;  # $Plugin::Graffiti::display
my $admin;    # $Plugin::Graffiti::admin

sub GraffitiAdmin
{
    my ($blosxom) = @_;
    my $admin_password = param('password');
    my $count = param('count');
    my $num_removed = 0;
    my @entries;
    my $realCachefile = "$blosxom->{settings}->{state_dir}/$cachefile";

    if ($require_password && ($password ne $admin_password))
    {
        $admin .= qq{<div class="graffiti_admin_response">Invalid Password!</div>\n};
        GraffitiAdminDisplay($blosxom);
        return;
    }

    # open the $realCachefile for reading/writing(append) and create if doesn't exist
    open(GRAFFITI, "+>>$realCachefile");
    flock(GRAFFITI, LOCK_EX);

    seek(GRAFFITI, 0, 0); # seek to the beginning of the cache file

    while ($line = <GRAFFITI>)
    {
        next if ($line =~ /^\s$/); # skip emtpy lines

        if ($line =~ /^-----\s$/)
        {
            push(@entries, $entry);
            $entry = '';
        }
        else
        {
            $entry .= qq{$line};
        }
    }

    foreach (param)
    {
        next if (!/^\d+$/); # only care about index/number params

        $entries[$_] = '';
        $num_removed++;
    }

    if ($num_removed == 0)
    {
        $admin .= qq{<div class="graffiti_admin_response">No entries were selected.</div>\n};
    }
    else
    {
        truncate(GRAFFITI, 0); # truncate the existing file

        foreach (@entries)
        {
            next if ($_ eq '');
            print(GRAFFITI "$_-----\n");
        }

        $admin .= qq{<div class="graffiti_admin_response">Number of entries removed: $num_removed</div>\n};
    }

    flock(GRAFFITI, LOCK_UN);
    close(GRAFFITI);

    GraffitiAdminDisplay($blosxom);
}


sub GraffitiAdminDisplay
{
    my ($blosxom) = @_;
    my $entry = '';
    my $count = 0;
    my $realCachefile = "$blosxom->{settings}->{state_dir}/$cachefile";

    # check administration IP address if restriction is turned on
    if ($restrict_admin_by_ip and !grep(/^\Q$ENV{'REMOTE_ADDR'}\E$/, @admin_ip_addrs))
    {
        $admin .= qq{<div class="graffiti_admin_response">Access denied from $ENV{'REMOTE_ADDR'}!</div>\n};
        $blosxom->{state}->{Plugin}->{Graffiti}->{admin} = $admin;
        return;
    }

    $admin .= qq{<div class="graffiti_admin">\n};
    $admin .= qq{<form class="graffiti_admin_form" method="POST" action="$blosxom->{settings}->{url}/index.graffiti">\n};
    $admin .= qq{<table class="graffiti_admin_table">\n};

    # open the $realCachefile for reading/writing(append) and create if doesn't exist
    open(GRAFFITI, "+>>$realCachefile");
    flock(GRAFFITI, LOCK_EX);

    seek(GRAFFITI, 0, 0); # seek to the beginning of the cache file

    while ($line = <GRAFFITI>)
    {
        next if ($line =~ /^\s$/); # skip emtpy lines

        if ($line =~ /^-----\s$/)
        {
            $admin .= qq{<tr class="graffiti_admin_row">\n};
            $admin .= qq{  <td class="graffiti_admin_cell">\n};
            $admin .= qq{    <input type="checkbox" name="$count" value="1" unchecked />\n};
            $admin .= qq{  </td>\n};
            $admin .= qq{  <td class="graffiti_admin_cell">\n};
            $admin .= qq{    $entry};
            $admin .= qq{  </td>\n};
            $admin .= qq{</tr>\n};

            $count++;
            $entry = '';
        }
        else
        {
            $entry .= qq{$line};
        }
    }

    flock(GRAFFITI, LOCK_UN);
    close(GRAFFITI);

    $admin .= qq{</table>\n};

    $admin .= qq{<div class="graffiti_admin_submit">\n};
    $admin .= qq{Password: <input class="graffiti_admin_password" name="password" size="15" value="" type="password" /><br />\n};
    $admin .= qq{<input type="hidden" name="plugin" value="graffiti_remove" />\n};
    $admin .= qq{<input type="hidden" name="count" value="$count" />\n};
    $admin .= qq{<input class="graffiti_admin_submit_button" type="submit" name="submit" value="Remove" />\n};
    $admin .= qq{</div>\n};

    $admin .= qq{</form>\n};
    $admin .= qq{</div>\n};

    $blosxom->{state}->{Plugin}->{Graffiti}->{admin} = $admin;
}


sub GraffitiDisplay
{
    my ($blosxom) = @_;
    my $new_entry = param('graffiti_entry');
    my $count = 0;
    my $entry = '';
    my @entries;
    my $new_entry_valid = 0;
    my $realCachefile = "$blosxom->{settings}->{state_dir}/$cachefile";

    $display .= qq{<div class="graffiti">\n};

    if ($new_entry)
    {
        # check new entry IP address if restriction is turned on
        if ($restrict_new_entry_by_ip and !grep(/^\Q$ENV{'REMOTE_ADDR'}\E$/, @new_entry_ip_addrs))
        {
            $display .= qq{<div class="graffiti_response">$error_string</div>\n} if ($display_feedback_string);
        }
        # filter entry if the filter restriction is turned on
        elsif ($filter_new_entries && ($new_entry =~ /$entry_filter/i))
        {
            $display .= qq{<div class="graffiti_response">$error_string</div>\n} if ($display_feedback_string);
        }
        else
        {
            $display .= qq{<div class="graffiti_response">$valid_string</div>\n} if ($display_feedback_string);

            $new_entry_valid = 1;
        }
    }

    $display .= qq{<form class="graffiti_form" method="POST" action="$blosxom->{settings}->{url}$blosxom->{request}->{path_info}">\n};
    $display .= qq{<textarea class="graffiti_text" readonly cols="$text_cols" rows="$text_rows">\n};

    # open the $realCachefile for reading/writing(append) and create if doesn't exist
    open(GRAFFITI, "+>>$realCachefile");
    flock(GRAFFITI, LOCK_EX);

    print(GRAFFITI "$new_entry\n-----\n") if ($new_entry_valid);

    seek(GRAFFITI, 0, 0); # seek to the beginning of the cache file

    while ($line = <GRAFFITI>)
    {
        next if ($line =~ /^\s$/); # skip emtpy lines

        if ($line =~ /^-----\s$/)
        {
            push(@entries, $entry);
            $entry = '';
        }
        else
        {
            $entry .= qq{$line};
        }
    }

    flock(GRAFFITI, LOCK_UN);
    close(GRAFFITI);

    foreach (reverse(@entries))
    {
        if (($entries_to_show == 0) || ($count++ < $entries_to_show))
        {
            $display .= qq{$_};
            $display .= qq{$entry_separator};
        }
        else
        {
            break;
        }
    }

    $display .= qq{</textarea>\n};
    $display .= qq{<textarea class="graffiti_entry" name="graffiti_entry" cols="$entry_cols" rows="$entry_rows">\n};
    $display .= qq{</textarea>\n};
    $display .= qq{<input class="graffiti_submit" type="submit" name="submit" value="Submit" />\n};
    $display .= qq{</form>\n};

    $display .= qq{</div>\n};

    $blosxom->{state}->{Plugin}->{Graffiti}->{display} = $display;
}


sub Run
{
    my $blosxom = shift;

    # if POSTing to the graffiti 'admin' interface then remove the specified entries
    if (request_method() eq 'POST' and param('plugin') eq 'graffiti_remove')
    {
        GraffitiAdmin($blosxom);
    }

    # else if the the graffiti flavour was specified then build the entry table
    elsif ($blosxom->{request}->{flavour} eq 'graffiti')
    {
        GraffitiAdminDisplay($blosxom);
    }

    # else another flavour is being shown so build the graffiti text area and
    # handle a new entry if one came in on the request
    else
    {
        GraffitiDisplay($blosxom);
    }

    return 1;
}

1;

__END__

=head1 NAME

Blosxom Plugin: graffiti

=head1 DESCRIPTION

This plugin provides a simple text form that allows visitors to your site to
add a brief comment, flame, kudo, splat, whatever.  A B<$Plugin::Graffiti::display>
variable is provided that contains two text boxes and a submit button.  One box
is used for entering in new text comments, and another that shows all
previously entered text comments.  The graffiti display can be modified via the
following configuration variables:

B<$entries_to_show>: the last N number of entries to show in the graffiti box, 0
means to show all entries

B<$entry_separator>: a string that is shown between all graffiti entries
in the text box

B<$text_rows>: the number of rows in the graffiti text area

B<$text_cols>: the number of columns in the graffiti text area

B<$entry_rows>: the number of rows in the graffiti new entry text area

B<$entry_rows>: the number of columns in the graffiti new entry text area

B<$cachefile>: the location of the cache file holding all the graffiti text

You can also configure this plugin to filter out and deny new entries.
First, you can configure a set of IP addresses that are allowed to submit
new entries.  Second, you create the regex that performs the filtering and
mostly it will be a simple 'or' seperated list of words (i.e. profanity).
The graffiti filtering can be modified via the following configuration
variables:

B<$restrict_new_entry_by_ip>: allow new graffiti entries only from a select
set of IP addresses (0 = no, 1 = yes)

B<@new_entry_ip_addrs>: list of IP addreses that have new entry submission access

B<$filter_new_entries>: turn on new entry filtering (0 = no, 1 = yes)

B<$entry_filter>: a regex string that is used to filter out new entries
(i.e. normally an 'or' separated list of words)

When a new graffiti entry is submitted, you can optionally have a response
string displayed back to the client.  The graffiti response can be modified
via the following configuration variables:

B<$display_feedback_string>: display a response string after a new entry is
submitted (0 = no, 1 = yes)

B<$error_string>: response string to display when a new entry has been
filtered/denied

B<$valid_string>: response string to display when a new entry has been accepted

The following class identifiers are used for CSS control of the graffiti
display:

B<graffiti>: the graffiti output as a whole

B<graffiti_response>: the response from a graffiti input

B<graffiti_form>: the graffiti form - text boxes and submit button

B<graffiti_text>: the graffiti text area

B<graffiti_entry>: the graffiti new entry text area

B<graffiti_submit>: the graffiti submit button

This plugin also provides a management interface that allows you to remove
specific graffiti entries that have been submitted.  A B<$Plugin::Graffiti::admin>
variable is provided that contains a form showing all the entries with
checkboxes, a password field, and a submit button.  You select which entries
you want removed, enter that password, and click the submit button.  The
graffiti administration interface can be modified via the following
configuration variables:

B<$require_password>: require a password to be submitted when administrating
graffiti entries (0 = no, 1 = yes)

B<$password>: the password that allows administration of graffiti entries

B<$restrict_admin_by_ip>: allow administration only from a select set of IP
addresses (0 = no, 1 = yes)

B<@admin_ip_addrs>: list of IP addreses that have administration access

The following class identifiers are used for CSS control of the graffiti
admin display:

B<graffiti_admin>: the graffiti admin output as a whole

B<graffiti_admin_response>: the reponse from a graffiti admin action

B<graffiti_admin_form>: the graffiti admin form - check boxes and submit button

B<graffiti_admin_table>: the graffiti admin table - check boxes with entries

B<graffiti_admin_row>: a row in the graffiti admin table

B<graffiti_admin_cell>: a cell in the graffiti admin table

B<graffiti_admin_submit>: the graffiti admin submit button and password entry

B<graffiti_admin_password>: the graffiti admin password entry

B<graffiti_admin_submit_button>: the graffiti admin submit button

Included with this plugin is a 'graffiti' flavour theme.  Drop the file into 
your theme directory, or break it out in the specific flavour files, and then
point your browser to 'index.graffiti'.  You will be presented with a graffiti
admin page which you can use to remove previously submitted entries.  If you
choose not to use this theme, simply use the B<$Plugin::Graffiti::admin> variable
anywhere in you existing flavour files to access the graffiti admin interface.

To run this plugin simply drop this file into your Blosxom plugin directory
and add B<$Plugin::Graffiti::Run> to your B<handlers.flow> file.

=head1 VERSION

3.2  lots of changes: max number of entries to show, restrict new
     entries to specific IPs, filter new entries based on content,
     new administration interface for removing previous entries,
     administration access to specific IPs and pasword

=head1 VERSION HISTORY

3.1  ported for use with Blosxom 3

=head1 AUTHORS

Eric Davis <edavis <at> foobargeek <dot> com> http://www.foobargeek.com

=head1 LICENSE

This source is submitted to the public domain.  Feel free to use and modify it.
If you like, a comment in your modified source attributing credit for my
original work would be appreciated.

THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT ANY WARRANTY OF ANY KIND.  USE AT
YOUR OWN RISK!


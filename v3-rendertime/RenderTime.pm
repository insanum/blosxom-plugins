# Blosxom v3 Plugin: RenderTime
# Author(s): Eric Davis <edavis@foobargeek.com>
# Documentation: See the bottom of this file or type: perldoc RenderTime.pm

package Blosxom::Plugin::RenderTime;

# --- Configurable variables -----

# log render times to the web server error log (1 = yes, 0 = no)
my $logToErrorLog = 0;

# log render times to a file (1 = yes, 0 = no)
my $logToFile = 0;

# the location of the log file to write times to
my $logFile = "rendertime.dat";

# log the render time to the generated page (1 = yes, 0 = no)
my $logToPage = 1;

# the string to search for and replace with the time in the generated page
my $replacement_string = "insert_rendertime_time_here";

# --------------------------------

# this code was taken directly from the perl faq

require 'sys/syscall.ph';

my $TIMEVAL_T = "LL";
my $startTime = pack($TIMEVAL_T, ());
my $endTime   = pack($TIMEVAL_T, ());

sub Start {
    syscall(&SYS_gettimeofday, $startTime, 0) != -1 or die "gettimeofday: $!";
    return 1;
}

sub Stop {
    my $blosxom = shift;

    syscall(&SYS_gettimeofday, $endTime, 0) != -1 or die "gettimeofday: $!";

    @start = unpack($TIMEVAL_T, $startTime);
    @end   = unpack($TIMEVAL_T, $endTime);

    for ($end[1], $start[1]) { $_ /= 1_000_000 }

    $time = sprintf "%.4f", ($end[0]  + $end[1]) - ($start[0] + $start[1]);

    if ($logToFile)
    {
        my $realLogFile = "$blosxom->{settings}->{state_dir}/$logFile";
        open(LOG, "+>>$realLogFile") or die "cannot write to file: $!.";
        print LOG "$ENV{'REQUEST_URI'} ($time)\n";
        close(LOG);
    }

    warn "$ENV{'REQUEST_URI'} ($time)\n" if ($logToErrorLog);

    if ($logToPage)
    {
	    $blosxom->{response}->{head}->{rendered} =~ s/$replacement_string/$time/g;

	    foreach ( @{$blosxom->{response}->{entries}} )
        {
            $blosxom->{entries}->{$_}->{rendered} =~ s/$replacement_string/$time/g;
	    }

	    $blosxom->{response}->{foot}->{rendered} =~ s/$replacement_string/$time/g;
    }

    return 1;
}

1;

__END__

=head1 NAME

Blosxom v3 Plugin: RenderTime

=head1 USAGE

This plugin is used to figure out how long it is taking for Blosxom to render a
page.  Drop this file into your Blosxom plugins directory and add
B<$Blosxom::Plugin::RenderTime::Start> right after the call to
B<$Blosxom::get_plugins> and B<$Blosxom::Plugin::RenderTime::Stop> right before
the call to B<$Blosxom::output_response> in your B<handlers.flow> file.
Then for each request this plugin will oompute the render time and log that
time to the configured location.  The log times are in seconds and are of
the form x.xxxx.  The following configuration variables are available:

B<$logToErrorLog>: log render times to the web server error log (1 = yes, 0 = no)

B<$logToFile>: log render times to a file (1 = yes, 0 = no)

B<$logFile>: the location of the log file to write render times to

B<$logToPage>: log the render time to the generated page (1 = yes, 0 = no)

B<$replacement_string>: the string to search for and replace with the render
time in the generated page

When the B<$logToPage> option is turned ON then a render time is computed
in the B<last> routine.  The B<last> routine is called by Blosxom before the
page is sent to the client.  This allows the render time to be injected into
the outgoing page wherever the B<$replacement_string> is found.  Therefore,
this render time will not be completely accurate.  Make note of whatever
plugins run after this plugins in the B<last> and B<end> routines as these
calls will not be part of the computed time.

The B<$logToErrorLog> and B<$logToFile> options always compute the render time
in the B<end> routine.  Therefore, these times are a bit more accurate.  Also,
for these two options the request URI is also logged as well.

This plugin requires the B<gettimeofday> system call.

=head1 VERSION

3.2  added ability to inject the render time within the page itself

=head1 VERSION HISTORY

3.1  ported for use with Blosxom 3

=head1 AUTHORS

Eric Davis <edavis@foobargeek.com> http://www.foobargeek.com

=head1 LICENSE

This source is submitted to the public domain.  Feel free to use and modify it.
If you like, a comment in your modified source attributing credit for my original
work would be appreciated.

THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT ANY WARRANTY OF ANY KIND.  USE AT YOUR OWN RISK!


# Blosxom v3 Plugin: headlines
# Author(s): Eric Davis <edavis <at> foobargeek <dot> com>
# $Id: Headlines.pm,v 3.1 2004/05/28 16:35:56 edavis Exp $
# Documentation: See the bottom of this file or type: perldoc headlines

package Blosxom::Plugin::Headlines;

# --- Configurable variables -----

# show dates for headlines and specifiy how to indent headlines
my $showDates = 0;
my $indent    = qq{};
#my $indent    = qq{nbsp;&nbsp;&nbsp;};

# set this to the file name used as the headline cache
my $cachefile = "headlines.dat";

# show long dates like "Jan 1, 2003"
# the default is to show dates like 1/1/2003
my $showLongDates = 0;

# how to sort the headline list (only set one of these to 1)
my $sortByDate              = 1;
my $sortByDateReverse       = 0;
my $sortByFilePathName      = 0;
my $sortByTitleAlphabetical = 0;

# number of headlines to present in the list (0 means show all)
my $numHeadlinesToShow = 30;

# --------------------------------

use CGI qw/:standard/;

my @monthabbr = qw{Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec};

sub Run
{
    my $blosxom = shift;
    my $count = 0;
    my $reindex = 0;
    my %blogs;
    my $display;
    my $realCachefile = "$blosxom->{settings}->{state_dir}/$cachefile";

    #$reindex = 1 if (CGI::param('reindex'));
    $reindex = 1;

    # open the $realCachefile for reading/writing(append) and create if doesn't exist
    open(CACHE, "+>>$realCachefile");

    # if the file was just created then force a reindex
    if ((stat($realCachefile))[7] == 0)
    {
        $reindex = 1;
    }

    if ($reindex) # re-cache all the headlines
    {
        truncate(CACHE, 0);

	    foreach ( keys %{$blosxom->{entries}} )
        {
            # grab the headline for this blog entry
            open(FILE, "<$_") or next;
            $headline = <FILE>;
            close(FILE);

            # cache this blog headline
            print(CACHE "$_=>$headline");
            $blogs{$_} = $headline;
        }
    }
    else
    {
        seek(CACHE, 0, 0); # seek to the beginning of the cache file

        # grab all the cached headlines
        while ($line = <CACHE>)
        {
            if ($line =~ /^(.*)=>(.*)$/)
            {
                $blogs{$1} = $2;
            }
        }
    }

    close(CACHE);

    $display .= qq{<ul class="headlines">\n};

    if ($sortByDate or $sortByDateReverse or $sortByFilePathName)
    {
        if ($sortByDate)
        {
		    @fr = sort { $blosxom->{entries}->{$b}->{mtime} <=> $blosxom->{entries}->{$a}->{mtime} } keys %{$blosxom->{entries}};
        }
        elsif ($sortByDateReverse)
        {
		    @fr = reverse sort { $blosxom->{entries}->{$b}->{mtime} <=> $blosxom->{entries}->{$a}->{mtime} } keys %{$blosxom->{entries}};
        }
        else # ($sortByFilePathName)
        {
            @fr = sort keys %{$blosxom->{entries}};
        }

        $lastMonth = 0;
        $lastDay   = 0;
        $lastYear  = 0;

        foreach (@fr)
        {
            my $mtime = $blosxom->{entries}->{$_};
            my @date  = localtime($mtime);
            my $month = $date[4] + 1;
            my $day   = $date[3];
            my $year  = $date[5] + 1900;

            $tmp = $blogs{$_};

            chomp($tmp);
            $_ =~ s/$blosxom->{settings}->{find_entries_dir}(.*)(txt)$/$blosxom->{settings}->{url}$1$blosxom->{request}->{flavour}/;

            if (($sortByDate or $sortByDateReverse) and $showDates)
            {
                if (($month != $lastMonth) or ($day != $lastDay) or ($year != $lastYear))
                {
                    if ($showLongDates)
                    {
                        $display .= qq{<li class="headlines_date">@monthabbr[$month-1] $day, $year</li>\n};
                    }
                    else
                    {
                        $display .= qq{<li class="headlines_date">$month/$day/$year</li>\n};
                    }

                    $lastMonth = $month;
                    $lastDay   = $day;
                    $lastYear  = $year;
                }

                $display .= qq{<li class="headlines_item"><a href="$_">$indent$tmp</a></li>\n};
            }
            else
            {
                $display .= qq{<li class="headlines_item"><a href="$_">$tmp</a></li>\n};
            }

            last if (($numHeadlinesToShow != 0) and (++$count == $numHeadlinesToShow));
        }
    }

    else # ($sortByTitleAlphabetical)
    {
        my %headline_hash;

        foreach ( keys %{$blosxom->{entries}} )
        {
            $tmp = $blogs{$_};

            chomp($tmp);
            $_ =~ s/$blosxom->{settings}->{find_entries_dir}(.*)(txt)$/$blosxom->{settings}->{url}$1$blosxom->{request}->{flavour}/;

            $headline_hash{$tmp} = $_;
        }

        foreach ( sort keys %headline_hash )
        {
            $display .= qq{<li class="headlines_item"><a href="$headline_hash{$_}">$_</a></li>\n};

            last if (($numHeadlinesToShow != 0) and (++$count == $numHeadlinesToShow));
        }
    }

    $display .= qq{</ul>\n};

    $blosxom->{state}->{Plugin}->{Headlines}->{display} = $display;

    return 1;
}

1;

__END__

=head1 NAME

Blosxom v3 Plugin: headlines

=head1 DESCRIPTION

This plugin provides a B<$Plugin::Headlines::display> variable that contains
a list of headlines for all the stories found by Blosxom.  Each headline in the
list is a path based permalink to the story.  The headlines presented can be
modified via the following configuration variables:

B<$sortByDate>: set to 1 for headlines sorted by date (earliest to latest)

B<$sortByDateReverse>: set to 1 for headlines sorted by date (latest to earliest)

B<$sortByFilePathName>: set to 1 for headlines sorted by the stories path/file name

B<$sortByTitleAlphabetical>: set to 1 for headlines sorted alphabetically

B<$numHeadlinesToShow>: the number of headlines to show in the list (0 means all)

B<$showDates>: show a date string before the headline (headlines occuring on the
same day fall under the same date headline)

B<$indent>: indent string inserted before a headline when B<$showDates> is on

B<$showLongDates>: show Jan 1, 2003 instead of 1/1/2003

Note that B<$sortByDate>, B<$sortByDateReverse>, B<$sortByFilePathName>, and
B<$sortByTitleAlphabetical> are mutually exclusive so only set one of them.
B<$showDates> only works when either B<$sortByDate> or B<$sortByDateReverse>
is being used.  The following class identifiers are used for CSS control of the
list:

B<headlines>: the unordered list as a whole

B<headlines_date>: a single headline date item in the unordered list

B<headlines_item>: a single headline item in the unordered list

To run this plugin simply drop this file into your Blosxom plugin directory
and add B<$Plugin::Headlines::Run> to your B<handlers.flow> file.  Note that
you will want to run this plugin very early (i.e. before any other plugins that
might modify the entries list).

The cache file is automatically created if it doesn't exist and the CGI
parameter setting B<?reindex=y> will force the cache file be re-generated.

=head1 VERSION

3.1    ported for use with Blosxom 3

=head1 VERSION HISTORY

3.1    ported for use with Blosxom 3

=head1 AUTHORS

Eric Davis <edavis <at> foobargeek <dot> com> http://www.foobargeek.com

=head1 LICENSE

This source is submitted to the public domain.  Feel free to use and modify it.
If you like, a comment in your modified source attributing credit for my original
work would be appreciated.

THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT ANY WARRANTY OF ANY KIND.  USE AT YOUR OWN RISK!


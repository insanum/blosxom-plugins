# Blosxom v3 Plugin: geek
# Author(s): Eric Davis <edavis <at> foobargeek <dot> com>
# $Id: Geek.pm,v 3.1 2004/05/28 16:35:56 edavis Exp $
# Documentation: See the bottom of this file or type: perldoc geek

package Blosxom::Plugin::Geek;

# --- Configurable variables -----

# geek the story title
my $geekTitle = 1;

# geek the story body
my $geekBody = 1;

# show all 8 bits for binary geek (default is 7)
# note that the 8th bit will always be 0 for ascii
my $showEightBits = 0;

# configure the width (number of bytes) for the "dump"
# style output, this must be a multiple of 2 for output
# to look correct
my $geekDumpWidth = 12;

# these are the label strings shown in the geek mode
# and geek list output variables

my %labels = ( nrm => 'normal',
               dmp => 'dump',
               hex => 'hexadecimal',
               oct => 'octal',
               dec => 'decimal',
               bin => 'binary' );

#my %labels = ( nrm => 'nrm',
#               dmp => 'dmp',
#               hex => 'hex',
#               oct => 'oct',
#               dec => 'dec',
#               bin => 'bin' );

# --------------------------------

my $geekmode = "";


sub Init {
    my $blosxom = shift;
    my $links = "";

    # check the CGI parameters for a geek setting

    if    ($blosxom->{cgi}->param('geek') eq 'dmp') { $geekmode = $labels{'dmp'}; }
    elsif ($blosxom->{cgi}->param('geek') eq 'hex') { $geekmode = $labels{'hex'}; }
    elsif ($blosxom->{cgi}->param('geek') eq 'oct') { $geekmode = $labels{'oct'}; }
    elsif ($blosxom->{cgi}->param('geek') eq 'dec') { $geekmode = $labels{'dec'}; }
    elsif ($blosxom->{cgi}->param('geek') eq 'bin') { $geekmode = $labels{'bin'}; }
    else                                            { $geekmode = $labels{'nrm'}; }

    # create the geek links for the current URL

    $links  = qq{<ul class="geek_links">\n};

    my $active = qq{<li class="geek_links_active_item">};
    my $item   = qq{<li class="geek_links_item">};
    my $anchor = qq{<a href="$blosxom->{settings}->{url}$blosxom->{request}->{path_info}};
    my $end    = qq{</a></li>\n};

    $links .= ($geekmode ne $labels{'nrm'}) ? qq{$item} : qq{$active};
    $links .= qq{$anchor">$labels{'nrm'}$end};

    $links .= ($geekmode ne $labels{'dmp'}) ? qq{$item} : qq{$active};
    $links .= qq{$anchor?geek=dmp">$labels{'dmp'}$end};

    $links .= ($geekmode ne $labels{'hex'}) ? qq{$item} : qq{$active};
    $links .= qq{$anchor?geek=hex">$labels{'hex'}$end};

    $links .= ($geekmode ne $labels{'oct'}) ? qq{$item} : qq{$active};
    $links .= qq{$anchor?geek=oct">$labels{'oct'}$end};

    $links .= ($geekmode ne $labels{'dec'}) ? qq{$item} : qq{$active};
    $links .= qq{$anchor?geek=dec">$labels{'dec'}$end};

    $links .= ($geekmode ne $labels{'bin'}) ? qq{$item} : qq{$active};
    $links .= qq{$anchor?geek=bin">$labels{'bin'}$end};

    $links .= qq{</ul>\n};

    $blosxom->{state}->{Plugin}->{Geek}->{links} = $links;

    return 1;
}


sub geek_it {
    my ($mode, $data) = @_;

    my $in_tag = 0;
    my $new_data = qq{<span class="geek_dump">\n};

    foreach (split/\n/, $data) 
    {
        # remove all beginning whitespace
        $_ =~ s/^\s+//;

        # remove all trailing whitespace
        $_ =~ s/\s+$//;

        # tack the newline back on so html source looks decent
        $_ =~ s/$/\n/;

        foreach (split(//))
        {
            # don't geek newlines
            if (/[\r\n]/) {
                $new_data .= $_;
                next;
            }

            # don't geek html tags
            # all character between a '<' and '>' (inclusive)
            if ($_ eq '<') { $in_tag = 1; }

            if ($in_tag) {
                $new_data .= $_;
                if ($_ eq '>') { $in_tag = 0; }
                next;
            }

            # geek this character

            if ($mode eq $labels{'hex'}) {
                $new_data .= sprintf("%02x", ord());
            }
            elsif ($mode eq $labels{'oct'}) {
                $new_data .= sprintf("%03o", ord());
            }
            elsif ($mode eq $labels{'dec'}) {
                $new_data .= sprintf("%03d", ord());
            }
            elsif ($mode eq $labels{'bin'}) {
                my $tmp = ord();

                if ($showEightBits) {
                    foreach my $i (0..7) {
                        $new_data .= (($tmp << $i) & 0x80) ? "1" : "0";
                    }
                }
                else {
                    foreach my $i (0..6) {
                        $new_data .= (($tmp << $i) & 0x40) ? "1" : "0";
                    }
                }
            }

            # add a space after every geek'ed character
            # this looks a lot better expecially during window resizes
            $new_data .= " ";
        }
    }

    $new_data .= qq{</span>\n};
    return $new_data;
}


sub geek_it_dump_character {
    my ($count, $cnt_col, $hex_col, $txt_col, $line_data, $ch) = @_;

    if (($$count % $geekDumpWidth) == 0) {
        # $geekDumpWidth bytes have been encoded on a line - start a new line
        if ($$line_data eq "") {
            $$cnt_col .= sprintf("%08x:&nbsp\;<br />\n", $$count);
        }
        else {
            $$hex_col .= "&nbsp\;&nbsp\;<br />\n";
            $$txt_col .= sprintf("%s<br />\n", $$line_data);
            $$cnt_col .= sprintf("%08x:&nbsp\;<br />\n", $$count);
            $$line_data = "";
        }
    }
    elsif (($$count % 2) == 0) {
        # still building an encoded $geekDumpWidth byte line
        $$hex_col .= "&nbsp\;";
    }

    $$count += 1;

    # add character to ascii data

    $_ = $ch;

    if    (/</)  { $$line_data .= "&lt\;"; }
    elsif (/>/)  { $$line_data .= "&gt\;"; }
    elsif (/&/)  { $$line_data .= "&amp\;"; }
    elsif (/\"/) { $$line_data .= "&quot\;"; }
    else         { $$line_data .= /[a-zA-Z0-9 ~`!@#\$%^\*()-_=\+\[{\]}\\|\;:',\.\/?]/ ? $_ : "."; }

    # geek this character

    $$hex_col .= sprintf("%02x", ord());
}


sub geek_it_dump {
    my ($data) = @_;

    my $in_tag = 0;
    my $count = 0;
    my $line_data = "";
    my $tag = "";
    my $tmp_data = "";
    my $new_data = qq{<span class="geek_dump"><table><tr>\n};

    my $cnt_col = "";
    my $hex_col = "";
    my $txt_col = "";

    foreach (split/\n/, $data) 
    {
        # remove all beginning whitespace
        $_ =~ s/^\s+//;

        # remove all trailing whitespace
        $_ =~ s/\s+$//;

        # tack the newline back on so html source looks decent
        $_ .= "\n";

        $tmp_data .= $_;
    }

    foreach (split(//, $tmp_data))
    {
        # html tag - all characters between a '<' and '>' (inclusive)
        if (/</) {
            $in_tag = 1;
            $tag = $_;
            next;
        }
        elsif ($in_tag) {
            $tag .= $_;

            if (/>/) {
                $in_tag = 0;
                $_ = $tag;

                # anchor and end anchor tags are left as is so links are still
                # available in the dump, all other html tags are geek'ed.
                if ((/^<\s*[aA]\s*.*>$/) or (/^<\s*\/\s*[aA]\s*>$/)) {
                    $hex_col .= $tag;
                    $line_data .= $tag;
                }
                else
                {
                    # geek the html tag
                    foreach (split(//))
                    {
                        geek_it_dump_character(\$count, \$cnt_col, \$hex_col, \$txt_col,
                                               \$line_data, $_);
                    }
                }
            }

            next;
        }

        geek_it_dump_character(\$count, \$cnt_col, \$hex_col, \$txt_col,
                               \$line_data, $_);
    }

    # pad with zeros to $geekDumpWidth byte alignment
    if (($count % $geekDumpWidth) != 0)
    {
        $pad = ($geekDumpWidth - ($count % $geekDumpWidth));

        foreach (1..$pad) {
            if (($count % 2) == 0) {
                $hex_col .= "&nbsp\;";
            }

            $count += 1;
            $line_data .= ".";

            $hex_col .= "00";
        }
    }

    $hex_col .= "&nbsp\;&nbsp\;<br />\n";
    $txt_col .= "$line_data<br />\n";
    $line_data = "";

    $new_data .= qq{<td>\n$cnt_col</td>\n};
    $new_data .= qq{<td>\n$hex_col</td>\n};
    $new_data .= qq{<td>\n$txt_col</td>\n};
    $new_data .= qq{</tr></table></span>\n};
    return $new_data;
}


sub Encode {
	my $blosxom = shift;

	if ($geekmode eq $labels{'nrm'}) {
        return 1;
    }

	if ($geekmode eq $labels{'dmp'}) {
        if ($geekTitle) {
            $blosxom->{state}->{current_entry}->{title} =
                geek_it_dump($blosxom->{state}->{current_entry}->{title});
        }
        if ($geekBody) {
            $blosxom->{state}->{current_entry}->{body} =
                geek_it_dump($blosxom->{state}->{current_entry}->{body});
        }
    }
    else {
        if ($geekTitle) {
            $blosxom->{state}->{current_entry}->{title} =
                geek_it($geekmode, $blosxom->{state}->{current_entry}->{title});
        }
        if ($geekBody) {
            $blosxom->{state}->{current_entry}->{body} =
                geek_it($geekmode, $blosxom->{state}->{current_entry}->{body});
        }
    }

    return 1;
}

1;


__END__

=head1 NAME

Blosxom v3 Plugin: geek

=head1 DESCRIPTION

This plugin is arguably the lamest, least-useful, most idiotic, extremely
demented, and coolest Blosxom plugin there is.  You'll either scratch your
head and say "What the...", or smile and say "That's awesome...".  This
plugin is used to present your stories in normal ascii, hexadecimal, octal,
decimal, binary, and the wicked memory dump form.

Other than the encoded story output there is a variable filled in by
geek that can be used within your themes.  The B<$Plugin::Geek::links>
variable is filled in with an unordered list that contains links to the
various geek encodings of the currently display URL.

If you don't want to use the B<$Plugin::Geek::links> list for accessing the
geek encodings you can simply tack on any of the following CGI strings to
a URL:

B<?geek=dmp>: the wicked memory dump format

B<?geek=hex>: hexadecimal format

B<?geek=oct>: octal format

B<?geek=dec>: decimal format

B<?geek=bin>: binary format

This plugin can be modified via the following configuration variables:

B<$geekTitle>: set to 1 to encode the story title

B<$geekBody>: set to 1 to encode the story body

B<$showEightBits>: set to 1 to show all 8 bits for binary encoding (note that
the 8th bit will always be zero for ascii)

B<$geekDumpWidth>: set this to the number of bytes per row in the memory
dump format (must be a multiple of 2)

B<%labels>: modify this list to the labels you want to see in your geek list

The following class identifiers are used for CSS control of the output:

B<geek_dump>: span label around the encoded title and/or story

B<geek_links>: unordered geek link list

B<geek_links_item>: an item in the unordered geek link list

B<geek_links_active_item>: an item in the unordered geek link list
(this one respresents the current geek mode being displayed)

To run this plugin simply drop this file into your Blosxom plugin directory
and add B<$Plugin::Graffiti::Init> to your B<handlers.flow> file and
B<$Plugin::Geek::Encode> to you B<handlers.entry> file.  Note that if your
using the meta plugin make sure that runs before this plugin so the meta
variables don't get geek'ed and presented in the output.

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


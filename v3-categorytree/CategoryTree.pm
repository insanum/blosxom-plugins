# Blosxom v3 Plugin: CategoryTree
# Author(s): Eric Davis <edavis <at> foobargeek <dot> com>
# $Id: CategoryTree.pm,v 3.1 2004/05/28 16:35:56 edavis Exp $
# Documentation: See the bottom of this file or type: perldoc CategoryTree

# Modifications for indentation and counts by: Eric Davis http://www.foobargeek.com

package Blosxom::Plugin::CategoryTree;

# --- Configurable variables -----

# If both $iWantIndents and $iDontWantSlashes are set then
# $iWantIndents is shown and $iDontWantSlashes is overridden.
# If neither are set then the normal directoy path with slashes
# is displayed.

# Set this to show an indented list tree.
my $iWantIndents = 1;

# This is the text used to indent a line one level to the right.
# You could use special character codes (i.e. lines, corners, etc)
my $indent = qq{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;};

# Use these settings to show the number of entries in a category.
my $iWantTheCount      = 1;
my $showCategoryIfZero = 0;
my $showCountIfZero    = 0;

# These strings are tacked onto the beginning/end of the count.
my $countPreStr        = "- ";
my $countPostStr       = "";

# Set this to 1 if you want the slashes removed from your display
# menu.  Only valid if $iWantIndents is 0.
my $iDontWantSlashes = 0;

# Make this equal to what you want the non-leading slashes
# replaced with when $iDontWantSlashes is 1.
my $slashReplacement = " :: ";

# --------------------------------

use File::Find;
use File::Basename;

sub Run
{
    my $blosxom = shift;
    my %categorycount;
    my $display;

	foreach ( keys %{$blosxom->{entries}} )
    {
        $tmp = $blosxom->{entries}->{$_}->{path};
        $_ =~ s/$blosxom->{settings}->{find_entries_dir}//;
        $tmp = dirname($_);

        while (!($tmp =~ /^\/$/))
        {
            if (exists($categorycount{$tmp}))
            {
                $categorycount{$tmp} += 1
            }
            else
            {
                $categorycount{$tmp} = 1;
            }

            $tmp = dirname($tmp);
        }

        if (exists($categorycount{$tmp}))
        {
            $categorycount{$tmp} += 1
        }
        else
        {
            $categorycount{$tmp} = 1;
        }
    }

    @categorytree = sort keys %categorycount;

    $display .= qq{<ul class="categorytree">\n};

    foreach $thing (@categorytree)
    {
        if (($categorycount{$thing} != 0) || $showCategoryIfZero)
        {
            my $displayString;

            if ($thing ne '/')
            {
                $displayString = $thing;
            }
            else
            {
                $displayString = '/root';
            }

            my $thisin;

            if ($iWantIndents)
            {
                $displayString =~ s!^\/!!;

                while ($displayString =~ s!((&nbsp\;)*)\w+\/!$1!)
                {
                    $thisin .= $indent;
                }
            }
            elsif ($iDontWantSlashes)
            {
                $displayString =~ s!^\/!!;
                $displayString =~ s!\/!$slashReplacement!g;
            }

            $display .= qq{<li class="categorytree_item">$thisin<a href="$blosxom->{settings}->{url}$thing">$displayString</a>};
            if ($iWantTheCount)
            {
                if (($categorycount{$thing} != 0) || $showCountIfZero)
                {
                    $display .= qq{ $countPreStr$categorycount{$thing}$countPostStr};
                }
            }

            $display .= qq{</li>\n};
        }
    }

    $display .= qq{</ul>};

    $blosxom->{state}->{Plugin}->{CategoryTree}->{display} = $display;

    return 1;
}

1;

__END__

=head1 NAME

Blosxom v3 Plugin: CategoryTree

=head1 USAGE

This plugin provides a B<$Plugin::CategoryTree::display> variable that can be
used in your flavour files wherever you want a list of your categories to go.
Each line holds the name of one category, each one linked to the appropriate
place in your Blosxom weblog.

By default a tree style list with indents is shown.  This is controlled by
the B<$iWantIndents> config variable.  If B<$iWantIndents> is set to 0
then then the normal directory path with slashes is displayed.  The
B<$iDontWantSlashes> and B<$slashReplacement> variables are used to modify
the normal directory path output.

You can also show the number of blogs in each category by setting
B<$iWantTheCount> equal to 1.  This will show the number of blogs to the
right of the category name.  A parent category will show the number of
blogs in itself and all children.  If B<$showCategoryIfZero> is equal to 1
then an empty category is displayed.  If B<$showCountIfZero> is equal to 1
then zero counts are displayed.  Lastly you can specify the text before
and after the count with B<$countPreStr> and B<$countPostStr>.

The following class identifiers are used for CSS control of the list:

B<categorytree>: the unordered list as a whole

B<categorytree_item>: a single category item in the unordered list

To run this plugin simply drop this file into your Blosxom plugin directory
and add B<$Plugin::CategoryTree::Run> to your B<handlers.flow> file.  Note that
you will want to run this plugin very early (i.e. before any other plugins that
might modify the entries list).

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


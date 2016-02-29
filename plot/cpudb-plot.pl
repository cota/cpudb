#!/usr/bin/perl

use Data::Dumper;

my $filename = $ARGV[0] or die "No filename provided\n";

my $favg = $filename;
$favg =~ s/(.*).dat/$1/;
$favg .= ".avg";

my @titles = ();

open(INPUT, "<$filename") or die ("Cannot open $filename: $!");
while (<INPUT>) {
    chomp;
    if ($_ =~ /#.*/) {
	@titles = split("\t");
	$titles[0] =~ s/#[ ]*(.*)/$1/;
	last;
    }
}
close(INPUT) or die "Cannot close $filename: $!";
die if !@titles;

# hash of titles for easy name->index conversion
my %titles = ();
for (my $i = 0; $i < @titles; $i++) {
    $titles[$i] =~ s/(.*):[0-9]+$/$1/;
    $titles{$titles[$i]} = $i + 1;
}

# 'set term' is set by the gnuplot invocation
print "set logscale y\n";
print "set yrange [1:]\n";
print "set xdata time\n";
print 'set timefmt "%Y-%m-%d"', "\n";
print 'set xrange ["1995-01-01":"2015-01-01"]', "\n";
print 'set xtics format "%Y"', "\n";
print "set key left top box opaque\n";
print "set title 'Microprocessors over time' font 'Arial,20'\n";

print "plot ";
my @pr = ();

my @ptstyles = (
    'pt 9 ps 0.6',
    'pt 7 ps 0.6',
    'pt 9 ps 0.6',
    'pt 7 ps 0.6',
    );
my @styles = (
    "lt 2 lw 1.2 lc rgb '#d8e400'",
    "lt 2 lw 1.2 lc rgb '#31d100'",
    "lt 2 lw 1.2 lc rgb '#cc0000'",
    "lt 2 lw 1.2 lc rgb '#0072bc'",
    );

sub pr {
    my ($field, $text, $style) = @_;

    my $index = $titles{$field} || die;
    push @pr, "'$filename' using 1:$index $ptstyles[$style] $styles[$style] title ''";
    push @pr, "'$favg' using 1:$index smooth bezier                       $styles[$style] title ''";
    push @pr, "-1 w linespoints $ptstyles[$style] $styles[$style] title '$text'";
}

my @print = (
    ['clock', 'Clock Frequency (MHz)'],
    ['transistors', 'Transistors (millions)'],
    ['tdp', 'Power (W)'],
    ['number_of_cores', 'Cores per socket']
    );

for (my $i = 0; $i < scalar(@print); $i++) {
    my $item = $print[$i];

    pr($item->[0], $item->[1], $i);
}

print join(", \\\n  ", @pr), "\n";

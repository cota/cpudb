#!/usr/bin/perl
# To get a relatively straight Bezier curve for the average trends,
# group microprocessors by year.

use warnings;
use strict;

my $filename = $ARGV[0] or die "No filename provided\n";

my $past;
my $pastname;
my @acc;
my $n;
my $n_cols;
open(INPUT, "<$filename") or die ("Cannot open $filename: $!");
while (<INPUT>) {
    chomp;
    if ($_ =~ /^# date/) {
	my (@arr) = split;
	$n_cols = scalar(@arr) - 1;
	die if $n_cols == -1;
    }
    if ($_ =~ /^[-0-9]+\t.*/) {
	die if !defined($n_cols);

	my ($date, $name, @arr) = split;
	$date =~ s/([0-9]+)-.*/$1/;
	if (!defined($past)) {
	    $past = $date;
	    $pastname = $name;
	}
	if ($date ne $past) {
	    pr();
	    $past = $date;
	    $pastname = $name;
	} else {
	    $n++;
	}
	for (my $i = 0; $i < @arr; $i++) {
	    $acc[$i] += $arr[$i];
	}
    }
}
close(INPUT) or die "Cannot close $filename: $!";

pr() if $n;

sub pr {
    if (!$n) {
	print $past;
	die;
    }
    my @arr = map { $_ / $n } @acc;
    print join("\t", "$past-07-01", $pastname, @arr), "\n";
    for (my $i = 0; $i < @acc; $i++) {
	$acc[$i] = 0;
    }
    $n = 1;
}

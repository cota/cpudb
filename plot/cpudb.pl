#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use CSVSlurp; # this is a local package that uses Text::CSV

my $cpudb_path = '..';

my %filenames = (
    caches	=> 'cache',
    codes	=> 'code_name',
    manufs	=> 'manufacturer',
    micros	=> 'microarchitecture',
    procs	=> 'processor',
    techs	=> 'technology',
    spec	=> 'spec_int2006',
);

sub cpudb_get {
    my ($attr) = @_;

    die if !$filenames{$attr};
    return CSVSlurp->load(file => "$cpudb_path/$filenames{$attr}.csv");
}

my %db = ();

foreach (keys %filenames) {
    $db{$_} = cpudb_get($_);
}

@{ $db{procs} } = grep {
    $_->{date} &&
    $_->{tdp} &&
    $_->{clock} &&
    $_->{transistors}
} @{ $db{procs} };

foreach my $proc (@{ $db{procs} }) {
    $proc->{cache} = $db{caches}->[$proc->{cache_on_id} - 1];
}

foreach my $proc (@{ $db{procs} }) {
    my %unknown = (
	name => 'Unknown',
    );
    if ($proc->{microarchitecture_id}) {
	$proc->{micro} = $db{micros}->[$proc->{microarchitecture_id} - 1];
    } else {
	$proc->{micro} = \%unknown;
    }
    if (!defined($proc->{micro}->{name})) {
	print Dumper($db{micros}->[0]);
	die ("micro id $proc->{microarchitecture_id}");
    }

    if ($proc->{manufacturer_id}) {
	$proc->{manuf} = $db{manufs}->[$proc->{manufacturer_id} - 1];
    } else {
	$proc->{manuf} = \%unknown;
	die;
    }

    if ($proc->{code_name_id}) {
	$proc->{code} = $db{codes}->[$proc->{code_name_id} - 1];
    } else {
	$proc->{code} = \%unknown;
    }
}

my @titles = qw/name number_of_cores number_of_threads clock proc_id tdp transistors/;
@titles = ('# date', @titles);
my $i = 0;

for (my $i = 0; $i < @titles; $i++) {
    my $j = $i + 1;
    $titles[$i] .= ":$j";
}
print join("\t", @titles), "\n";
my @groups = ();
foreach my $proc (sort { $a->{date} cmp $b->{date} } @{ $db{procs} }) {
    my $n_threads = $proc->{hw_nthreadspercore} * $proc->{hw_ncores};
    my $name = "$proc->{manuf}->{name} $proc->{micro}->{name} $proc->{code}->{name}";
    $name =~ s/\s/_/g;

    my $line = join("\t",
		    $proc->{date},
		    $name,
		    $proc->{hw_ncores},
		    $n_threads,
		    $proc->{clock},
		    $proc->{processor_id},
		    $proc->{tdp},
		    $proc->{transistors},
	);
    push @groups, $line;
}
print join("\n", @groups);

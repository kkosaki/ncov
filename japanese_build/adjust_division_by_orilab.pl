#!/usr/bin/perl

my $metadata=$ARGV[0];
my $orilab_inst=$ARGV[1];

open(FILE, $orilab_inst) || die "can not open a file: $orilab_inst";
my %inst_pref;

while(<FILE>) {
	chomp;
	my @line = split(/\t/, $_);
	$inst_pref{ $line[0] } = $line[1];
}
close(FILE);

#replace meatadata
open(FILE, $metadata) || die "can not open a file: $metadata";

while(<FILE>) {
	chomp;
	my @line = split(/\t/, $_);
	
	foreach my $tmp ( keys %inst_pref ) { 
		if ( exists $inst_pref{ $line[20] } ) {
			$line[7] = $inst_pref{ $line[20] };
		}
	}

	print join("\t", @line);
	print "\n";
}

close(FILE);



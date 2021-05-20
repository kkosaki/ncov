#!/usr/bin/perl


my $file=$ARGV[0];

#replace meatadata
open(FILE, $file) || die "can not open a file: $file";

while(<FILE>) {
	chomp;
	my @line = split(/\t/, $_);
	#0: strain location(Region,Country,Division,Location:5-8 exposure region/country/division:9-11
	if ( $line[0] =~ /Japan\// ) {
		# country != country_exposure 
		if ( $line[6] ne $line[10] ) {
			$line[7] = "JapanQuarantine"; #set JapanQuarantine 
		}
	}
	print join("\t", @line);
	print "\n";
}
close(FILE);
__END__


#!/usr/bin/perl


my $file=$ARGV[0];

open(FILE, $file) || die "can not open a file: $file";

while(<FILE>) {
	chomp;
	my @line = split(/\t/, $_);
	#Region,Country,Division,Location:column 5-8 exposure region/country/division:column 9-11
	if ( $line[0] =~ /Japan\/IC-/ ) {
		# country != country_exposure 
		#if ( $line[6] ne $line[10] ) {
       #                 $line[6] = "JapanQuarantine"; #set JapanQuarantine as Country  
		#	$line[7] = "JapanQuarantine"; #set JapanQuarantine as Divisioin
		#}

      if ( $line[0] =~ /Japan\/IC-/ ) {
           $line[6] = "JapanQuarantine"; #set JapanQuarantine as Country  
		    $line[7] = "JapanQuarantine"; #set JapanQuarantine as Divisioin
		}
	}
	print join("\t", @line);
	print "\n";
}
close(FILE);
__END__


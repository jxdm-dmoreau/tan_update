#!/usr/bin/perl -w
#
#
use strict;
use Encode;

sub convert {
	my @extract = split(//,$_);
	my $string = "";
	foreach(@extract) {
		$_ = decode("cp1252", $_);
		$_ = encode("utf-8", $_);
		# Convert Oe
		if(/\x{c5}/ && /\x{92}/) {
			s/\x{92}/\x{65}/;
			s/\x{c5}/\x{4f}/;
		}
		# Convert oe
		if(/\x{93}/ && /\x{c5}/) {
			s/\x{93}/\x{65}/;
			s/\x{c5}/\x{6f}/;
		}
		# convert l'apostrophe
		if(/\x{c2}/ && /\x{b4}/) {
			s/\x{b4}/\x{27}/;
			s/\x{c2}//;
		}
		$string .= $_;
	}
	return $string;
}



my $file = $ARGV[0];


open(FILE,$file);
while(<FILE>) {
	$_ = convert($_);
	print $_;
}
close(FILE);

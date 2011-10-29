#!/usr/bin/perl -w
use strict;

my @dict = qw/aq w e r t y u i o p a s d f g h j k l z x c v b n m/;
foreach my $size (70 .. 85) {
	my $clear = '';
	$clear .= $dict[int(rand(scalar(@dict)))] foreach 1 .. $size;
	
	my $ciphertext = `echo "$clear" | openssl bf -pass pass:testing -base64`;
	# Command to decrypt is `echo "$ciphertext" | openssl bf -d -base64 -pass pass:testing`;

	my $result = length($ciphertext);
	print "For a message of size $size, ciphertext is $result chars long\n";
}

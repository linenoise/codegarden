package Tinhorn::App::ForexBot;

use strict;

=head1 NAME

Tinhorn::App::ForexBot - The Tinhorn Foreign Exchange data harvesting bot

=head1 SYNOPSIS

	my $app = new Tinhorn::App::ForexBot;
	my $pid = $app->start();

=head1 DESCRIPTION

This is the Tinhorn Forex data harvester.

=cut

use Tinhorn;
use Tinhorn::Model::Currency;
use Tinhorn::Model::ExchangeRate;
use Tinhorn::Bridge::YahooFinance;

sub start {
	
	$| = 1;  ### Autoflush!  Yeah!
	
	print "ForexBot starting.\n";
	
	### What date is it?
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $date_stamp = sprintf('%04d-%02d-%02d', $year+1900,$mon+1,$mday);
	print "   - for $date_stamp\n";
	
	### Load currencies
	print "   - loading currencies... ";
	my @currencies = map({$_->{code}} Tinhorn::Model::Currency::all());
	print join(', ', @currencies)."\n";
	
	### Determine which exchange rates we already have for today
	print "   - loading exchange rates already polled for today... ";
	my %available;
	my @exchange_rates = Tinhorn::Model::ExchangeRate::find({'quote_date' => $date_stamp});
	print scalar(@exchange_rates);
	foreach my $pair (@exchange_rates) {
		$available{$pair->{base_currency}.$pair->{quote_currency}} = 1;
		$available{$pair->{quote_currency}.$pair->{base_currency}} = 1;
	}
	print "\n";
	
	### Determine currency pairs needed
	print "   - determining currency pairs... ";
	my @pairs;
	foreach my $base (@currencies) {
		foreach my $quote (@currencies) {
			next if $base eq $quote;
			unless ($available{"$base$quote"} || $available{"$quote$base"}) {
				push @pairs, "$base$quote";
				$available{"$base$quote"} = 1;
				$available{"$quote$base"} = 1;
			}
		}
	}
	
	if (scalar(@pairs)) {
		print scalar(@pairs)." ready to run.\n";		
	} else {
		print "\nNo runs needed for today.\n";
		exit 0;
	}


	### Chunk them into queries consisting of 90 pairs each
	print "   - chunking queries... ";
	my @queries;
	my ($index, $level) = (0,0);
	foreach my $pair (@pairs) {
		$queries[$level] ||= ();
		push @{$queries[$level]}, $pair;
		$index++;
		if ($index == 60) {
			$index = 0;
			$level++;
		}
	}
	foreach my $level (0..scalar(@queries)-1) {
		print scalar(@{$queries[$level]}).' ';
	}
	print "\n";

	### Query them against the Yahoo! Finance API
	print "\nQuerying Yahoo! Finance API...\n";
	my $yahoo_finance = new Tinhorn::Bridge::YahooFinance;
	foreach my $layer (0..scalar(@queries)-1) {
		my @chunk = @{$queries[$layer]};
		
		foreach my $exchange_rate ($yahoo_finance->get_exchange_rate(@chunk)) {
			
			$exchange_rate->{quote_date} = $date_stamp;
			
			### Save Base -> Quote
			new Tinhorn::Model::ExchangeRate($exchange_rate)->save();

			### Save Quote -> Base
			my $temp = $exchange_rate->{base_currency};
			$exchange_rate->{base_currency} = $exchange_rate->{quote_currency};
			$exchange_rate->{quote_currency} = $temp;
			$exchange_rate->{quote_rate} = int (10000 / $exchange_rate->{quote_rate}) / 1000 unless $exchange_rate->{quote_rate} == 0;
			new Tinhorn::Model::ExchangeRate($exchange_rate)->save();
			
			print '.';
			
		}
		print "sleeping";
		sleep 10;
		print "\n";
	}

	print "\nForexBot run complete.\n";
}



=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
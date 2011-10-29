package Tinhorn::View::Currencies;

use strict;

=head1 NAME

Tinhorn::View::Currencies - The Tinhorn /currencies view

=head1 SYNOPSIS

	### Meanwhile, back in Tinhorn::App::Webserver::Router
	use Tinhorn::View::Currencies;
	load_routes_from(%Tinhorn::View::Currencies::routes);
	
=head1 DESCRIPTION

This module shows basic currencies information

=head1 METHODS

=over 4

=cut

use Tinhorn::View qw/render/;
use base qw(Tinhorn::View);

use Tinhorn::Model::Currency;
use Tinhorn::Model::ExchangeRate;

our %routes = (
	'/currencies' => *default,
	'/currencies/view' => *view,
);


=item C<default>

/currencies - The currencies summary page.

=cut
sub default {
	my ($cgi) = @_;
		
	my @currencies = sort( {$a->{code} cmp $b->{code}} Tinhorn::Model::Currency::all());
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $today_date = sprintf('%04d-%02d-%02d', $year+1900,$mon+1,$mday);

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time()-60*60*24);
	my $yesterday_date = sprintf('%04d-%02d-%02d', $year+1900,$mon+1,$mday);

	my @exchange_rates = Tinhorn::Model::ExchangeRate::find({'quote_date' => $today_date});
	my @yesterday_rates = Tinhorn::Model::ExchangeRate::find({'quote_date' => $yesterday_date});

	my %exchange_rates;
	my %yesterday_rates;
	my %rate_changes;
	my %change_colors;
	
	foreach my $pair (@yesterday_rates) {
		$yesterday_rates{$pair->{base_currency}}->{$pair->{quote_currency}} = $pair->{quote_rate};
	}
	foreach my $pair (@exchange_rates) {
		my $yesterday = $yesterday_rates{$pair->{base_currency}}->{$pair->{quote_currency}};
		my $today = $exchange_rates{$pair->{base_currency}}->{$pair->{quote_currency}} = $pair->{quote_rate};
		$rate_changes{$pair->{base_currency}}->{$pair->{quote_currency}} = 
			($today - $yesterday) / $yesterday 
			if $yesterday;
		
		my $color_point = $rate_changes{$pair->{base_currency}}->{$pair->{quote_currency}} * 1000;

		if ($color_point < -10) {
			$change_colors{$pair->{base_currency}}->{$pair->{quote_currency}} = 'down3' 

		} elsif ($color_point < -5) {
			$change_colors{$pair->{base_currency}}->{$pair->{quote_currency}} = 'down2' 

		} elsif ($color_point < -1) {
			$change_colors{$pair->{base_currency}}->{$pair->{quote_currency}} = 'down1' 

		} elsif ($color_point < 1) {
			$change_colors{$pair->{base_currency}}->{$pair->{quote_currency}} = 'hold' 

		} elsif ($color_point < 5) {
			$change_colors{$pair->{base_currency}}->{$pair->{quote_currency}} = 'up1' 

		} elsif ($color_point < 10) {
			$change_colors{$pair->{base_currency}}->{$pair->{quote_currency}} = 'up2' 

		} else {
			$change_colors{$pair->{base_currency}}->{$pair->{quote_currency}} = 'up3' 

		} 
	}
	

	my $content = render('currencies/default.tt',{
		today_date => $today_date,
		currencies => \@currencies,
		exchange_rates => \%exchange_rates,
		change_colors => \%change_colors,
	});
		
	### Respond with the results
	return {
		currencies 			=> 200,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<view>

/currencies/view - The currencies view page.

=cut
sub view {
	my ($cgi) = @_;
	
	if (my $base_code = $cgi->param('base')) {

		my @currencies = sort( {$a->{code} cmp $b->{code}} Tinhorn::Model::Currency::all());

		my $currency = Tinhorn::Model::Currency::get({code => $base_code});
		
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		my $today_date = sprintf('%04d-%02d-%02d', $year+1900,$mon+1,$mday);

		my @exchange_rates = Tinhorn::Model::ExchangeRate::find({
			'quote_date' => $today_date, 
			base_currency => $base_code
		});
		my %exchange_rates;
		foreach my $pair (@exchange_rates) {
			$exchange_rates{$pair->{base_currency}}->{$pair->{quote_currency}} = $pair->{quote_rate};
		}

		my $content = render('currencies/view.tt',{
			today_date => $today_date,
			currency => $currency,
			currencies => \@currencies,
			exchange_rates => \%exchange_rates,
		});

		### Respond with the results
		return {
			currencies 			=> 200,
			content_type	=> 'text/html',
			content 		=> $content,
		};
		
	} else {
		return default($cgi);
	}
	
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
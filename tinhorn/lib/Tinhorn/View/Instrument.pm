package Tinhorn::View::Instrument;

use strict;

=head1 NAME

Tinhorn::View::Instrument - The Tinhorn /instrument view

=head1 SYNOPSIS

	### Meanwhile, back in Tinhorn::App::Webserver::Router
	use Tinhorn::View::Instrument;
	load_routes_from(%Tinhorn::View::Instrument::routes);
	
=head1 DESCRIPTION

This view-layer module allows a user to view details on a specific financial instrument

=head1 METHODS

=over 4

=cut

use Tinhorn::View qw/render/;
use base qw(Tinhorn::View);

our %routes = (
	'/instrument' => *instrument,
);

our @months = qw/January February March April May June July August September October November December/;

=item C<instrument>

/instrument - The home page.

=cut
sub instrument {
	my ($cgi) = @_;
	
	my $exchange = $cgi->param('e');
	my $symbol = $cgi->param('s');
	$exchange =~ s/[[:^alpha:]]//g;
	$symbol =~ s/\W//g;
	
	my ($content, $http_code) = ('', 200);
	if ($exchange && $symbol) {

		my @exchanges = Tinhorn::Model::Exchange->search(symbol => $exchange);
		if (scalar(@exchanges)) {
			
			my @instruments = Tinhorn::Model::Instrument->search(
				exchange_id => $exchanges[0]->{id},
				symbol      => $symbol,
			);
			if (scalar(@instruments)) {
				my $instrument = $instruments[0];
				my $vars = {
					exchange 		=> $exchange,
					symbol   		=> $symbol,
					name			=> $instrument->name,
					description		=> $instrument->description,
					home_url		=> $instrument->home_url,
					wikipedia_url	=> $instrument->wikipedia_url,
				};
				
				### Load up Google, Reuter's, and Yahoo chart URLs if available
				if (my $google_finance_url = $instrument->google_finance_url()) {
					$vars->{google_finance_url} = $google_finance_url;
				}
				if (my $reuters_finance_url = $instrument->reuters_finance_url()) {
					$vars->{reuters_finance_url} = $reuters_finance_url;
				}
				if (my $yahoo_finance_url = $instrument->yahoo_finance_url()) {
					$vars->{yahoo_finance_url} = $yahoo_finance_url;
				}
				
				### Load up their financials
				my $id = $instrument->id;
				
				my $yesterday_rate = 0;
				my $today_rate = 0;
				my $market_rate_pair = Tinhorn::Model::MarketRate->retrieve_from_sql(qq{
					instrument_id = $id			AND
					interval_code = 'D'
				    ORDER BY quoted_on desc 
					LIMIT 2
				});
				if (my $rate = $market_rate_pair->next()){
					$today_rate = $rate;
				}
				if (my $rate = $market_rate_pair->next()){
					$yesterday_rate = $rate;
				}
				
				if ($yesterday_rate && $today_rate) {
					my ($year, $month, $day) = split /-/, $today_rate->quoted_on;
					my $percent_change = sprintf('%5.2f% ',
						($today_rate->close - $yesterday_rate->close) * 100 / 
						$yesterday_rate->close
					);
					$vars->{financials}->{quote_date} = $months[$month-1]." $day, $year";
					$vars->{financials}->{price} = sprintf('%5.2f',$today_rate->close);
					$vars->{financials}->{currency} = $instrument->currency_id->code;

					$vars->{financials}->{price_change} = sprintf('%5.2f',$today_rate->close - $yesterday_rate->close);
					$vars->{financials}->{price_change_percent} = $percent_change;
					$vars->{financials}->{rating} = '--';
					$vars->{financials}->{rating_bar_size} = (($vars->{financials}->{rating} - 1) * 100 / 4.05);
					$vars->{financials}->{rating_description} = '--';
					$vars->{financials}->{previous_close} = sprintf('%5.2f',$yesterday_rate->close);
					$vars->{financials}->{high} = sprintf('%5.2f',$today_rate->high);
					$vars->{financials}->{volume} = $today_rate->volume; 
					$vars->{financials}->{open} = sprintf('%5.2f',$today_rate->open);
					$vars->{financials}->{low} = sprintf('%5.2f',$today_rate->low);
					$vars->{financials}->{earnings_per_share} = '--';
				}
				
				### Load data for the graph
				my $graph_points = [];
				my $iterator = Tinhorn::Model::MarketRate->retrieve_from_sql(qq{
					instrument_id = $id			AND
					interval_code = 'D'			AND
					datediff(now(), quoted_on) < 30
				    ORDER BY quoted_on desc 
				 });
				my $index = 0;
				while (my $market_rate = $iterator->next()) {
					push @$graph_points, {
						index   => $index--,
						close	=> $market_rate->close,
						date	=> $market_rate->quoted_on,
						volume	=> $market_rate->volume,
					};
				}
				$vars->{financials}->{graph_points} = $graph_points;

				$content = render('instrument.tt',$vars);
				
			} else {
				$http_code = 404;
				$content = 'Unknown instrument';
			}
		} else {
			$http_code = 404;
			$content = 'Unknown exchange';
		}
	} else {
		$http_code = 404;
		$content = 'Unknown exchange or symbol';
	}
	
	return {
		home 			=> $http_code,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
package Tinhorn::Bridge::YahooFinance;

use strict;

=head1 NAME

Tinhorn::Bridge::YahooFinance - The Tinhorn bridge to the Yahoo! Finance API

=head1 SYNOPSIS

	use Tinhorn::Bridge::YahooFinance;
	my $yahoo_finance = new Tinhorn::Bridge::YahooFinance;
	my @exchange_rates = $yahoo_finance->get_exchange_rate('USDEUR', 'EURGBP');

=head1 DESCRIPTION

This is the Tinhorn Yahoo! Finance bridge.  It lets us query exchange rates

=back

=head1 METHODS

=over 4

=cut

use base qw/Tinhorn::Bridge::_HTTP/;


our %field_symbols = (
    'symbol'									=>  's',
    'name'										=>  'n',
	'last_trade'								=>  'l1',
    'last_trade_date'							=>  'd1',
    'last_trade_time'							=>  't1',
    'last_trade_size'							=>  'k3',
    'change'									=>  'c1',
    'percent_change'							=>  'p2',
    'ticker_trend'								=>  't7',
    'volume'									=>  'v',
    'average_daily_volume'						=>  'a2',
    'more_info'									=>  'i',
    'trade_links'								=>  't6',
    'bid'										=>  'b',
    'bid_size'									=>  'b6',
    'ask'										=>  'a',
    'ask_size'									=>  'a5',
    'previous_close'							=>  'p',
    'open'										=>  'o',
    'days_range'								=>  'm',
    '52week_range'								=>  'w',
    'change_from_52_week_low'					=>  'j5',
    'percent_change_from_52_week_low'			=>  'j6',
    'change_from_52_week_high'					=>  'k4',
    'percent_change_from_52_week_high'			=>  'k5',
    'earnings_per_share'						=>  'e',
    'price_to_earnings_ratio'					=>  'r',
    'short_ratio'								=>  's7',
    'dividend_pay_date'							=>  'r1',
    'ex_dividend_date'							=>  'q',
    'dividend_per_share'						=>  'd',
    'dividend_yield'							=>  'y',
    'float_shares'								=>  'f6',
    'market_capitalization'						=>  'j1',
    '1_year_target_price'						=>  't8',
    'EPS_estimate_for_current_year'				=>  'e7',
    'EPS_estimate_for_next_year'				=>  'e8',
    'EPS_estimate_for_next_quarter'				=>  'e9',
    'price_per_EPS_estimate_for_current_year'	=>  'r6',
    'price_per_EPS_estimate_for_next_year'		=>  'r7',
    'PEG_ratio'									=>  'r5',
    'book_value'								=>  'b4',
    'price_to_book'								=>  'p6',
    'price_to_sales'							=>  'p5',
    'EBITDA'									=>  'j4',
    '50_day_moving_average'						=>  'm3',
    'change_from_50_day_moving_average'			=>  'm7',
    'percent_change_from_50_day_moving_average'	=>  'm8',
    '200_day_moving_avg'						=>  'm4',
    'change_from_200_day_moving_avg'			=>  'm5',
    'percent_200_day_moving_avg'				=>  'm6',
    'stock_exchange'							=>  'x'	
);

our %symbol_fields = ();  ### Reverse mapping of the above.
$symbol_fields{$field_symbols{$_}} = $_ foreach keys %field_symbols;


=item C<_generate_fieldset>

Generates a Yahoo! Finance field set from human-readable params

Takes: C<$self>, C<@params> -- an array containing scalars matching any of: 1_year_target_price, 200_day_moving_avg, 50_day_moving_average, 52week_range, EBITDA, EPS_estimate_for_current_year, EPS_estimate_for_next_quarter, EPS_estimate_for_next_year, PEG_ratio, ask, ask_size, average_daily_volume, bid, bid_size, book_value, change, change_from_200_day_moving_avg, change_from_50_day_moving_average, change_from_52_week_high, change_from_52_week_low, days_range, dividend_pay_date, dividend_per_share, dividend_yield, earnings_per_share, ex_dividend_date, float_shares, last_trade_date, last_trade_size, last_trade_time, market_capitalization, more_info, name, open, percent_200_day_moving_avg, percent_change, percent_change_from_50_day_moving_average, percent_change_from_52_week_high, percent_change_from_52_week_low, previous_close, price_per_EPS_estimate_for_current_year, price_per_EPS_estimate_for_next_year, price_to_book, price_to_earnings_ratio, price_to_sales, short_ratio, stock_exchange, symbol, ticker_trend, trade_links, volume

Returns: C<$fieldset> -- a fieldset SCALAR suitable for passing to _get_quote.

=cut
sub _generate_fieldset {
	my ($self, @fields) = @_;
	
	my $fieldset = '';
	
	foreach my $field (@fields) {
		$fieldset .= $field_symbols{$field};
	}
	
	return $fieldset;
}


=item C<_decode_fieldset>

Decodes a Yahoo! Finance field set into human-readable params

Takes: C<$self>, C<$fieldset>

Returns: C<@fields> -- an array of human-readable field parameters

=cut
sub _decode_fieldset {
	my ($self, $fieldset) = @_;
	
	my @fields;
	
	$fieldset =~ s/(\w\d?)/push @fields, $symbol_fields{$1} /sexg;
	
	return @fields;
}


=item C<_get_quote_for>

Retrieves quote information for a financial instrument from Yahoo! Finance API

Takes: 

=over 4

=item C<$self>

=item C<$symbols> -- ARRAY REF containing symbols to lookup.

=item C<$fieldset> -- a SCALAR containing factors to look up (e.g. 'sl1d1t1c1ohgv'), from:

=back

Returns: @quotes on success, undef on failure.  On success, @quote is just an array ref of hashrefs containing factors you asked for.

=cut
sub _get_quotes_for {
	my ($self, $symbols, $fieldset) = @_;
	
	my $query = join('+', @$symbols);	
	my $uri = "http://download.finance.yahoo.com/d/quotes.csv?s=$query&f=$fieldset&e=.csv";
	
	my $response = $self->http_get($uri, {no_mockup => 1});
	unless($response->is_success()) {
		print "Yahoo Finance API HTTP request was unsuccessful\n";
		return;
	}

	my $quotes = $response->content();
	unless(scalar($quotes)) {
		print "No data returned by Yahoo Finance API\n";
		return;
	}
	
	my @quotes = ();
	my @fields = $self->_decode_fieldset($fieldset);
	
	foreach my $quote (split /\r\n/, $quotes) {
		my (@values) = split /,/, $quote;
		my $quote = {};
		foreach my $index (0..scalar(@values)-1) {
			$quote->{$fields[$index]} = $values[$index];
		}
		push @quotes, $quote;
	}
	
	return @quotes;
}


=item C<get_exchange_rates>

Returns exchange rate quotes from the Yahoo! Finance API

Takes: C<$self>, C<@pairs> (e.g. ('EURUSD', 'EURGBP'))

Returns on success: @exchange_rates, which looks like

	$VAR1 = {
	          'base_currency' => 'USD',
	          'quote_rate' => '0.733',
	          'quote_currency' => 'EUR',
	          'quote_date' => '2010-04-12'
	        };
	$VAR2 = {
	          'base_currency' => 'EUR',
	          'quote_rate' => '0.8838',
	          'quote_currency' => 'GBP',
	          'quote_date' => '2010-04-12'
	        };
	
Returns on failure: undef

=cut
sub get_exchange_rate {
	my ($self, @pairs) = @_;
	
	my @symbols = map({"$_=X"} @pairs);
	my @quotes = $self->_get_quotes_for(\@symbols, 'sl1d1');
	
	my @exchange_rates;
	foreach my $quote (@quotes) {
		my ($base_currency, $quote_currency, $quote_rate, $quote_date);
		$quote->{symbol} =~ s/(\w{3})(\w{3})=X/ $base_currency = $1; $quote_currency = $2 /sexg;
		$quote_rate = $quote->{last_trade};
		$quote->{last_trade_date} =~ s/(\d*?)\/(\d*?)\/(\d{4})/$quote_date = sprintf('%04d-%02d-%02d',$3,$1,$2)/sexg;
		push @exchange_rates, {
			base_currency  => $base_currency,
			quote_currency => $quote_currency,
			quote_rate     => $quote_rate,
			quote_date     => $quote_date,
		};
	}
	
	return @exchange_rates;
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut
1;
__END__
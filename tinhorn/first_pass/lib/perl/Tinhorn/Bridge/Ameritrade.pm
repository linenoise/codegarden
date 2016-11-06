package Tinhorn::Bridge::Ameritrade;

use strict;

=head1 NAME

Tinhorn::Bridge::Ameritrade - The Tinhorn bridge to the TD Ameritrade API

=head1 SYNOPSIS

	my $ameritrade = new Tinhorn::Bridge::Ameritrade;

	$ameritrade->login();

	### Get a stock, option, index, or mutual fund quote
	my $quote = $ameritrade->get_quote('AAPL');
	
	### Lookup a stock, option, index, or mutual fund symbol
	my $results = $ameritrade->lookup_symbol_for('Southwest');

	$ameritrade->logout();

=head1 DESCRIPTION

This is the Tinhorn Ameritrade API.  It lets us get quotes on stocks, indices, options, and mutual funds.  It also lets us buy and sell financial instruments.

=head1 TODO

=over 4

=Item store sessions to some SQL table so we know when we do and do not have to re-login.

=back

=head1 METHODS

=over 4

=cut

use base qw/Tinhorn::Bridge::_HTTP/;

use XML::Simple;


=item C<login>

Logs in to TD Ameritrade API

Takes: $self

Returns on success: $session (which gets crammed into $self->{session}), which looks like

	$VAR1 = {
	          'opra-quotes' => 'realtime',
	          'nasdaq-quotes' => 'realtime',
	          'associated-account-id' => '757415492',
	          'cdi' => 'A000000024055413',
	          'user-id' => 'dannestayskal',
	          'session-id' => 'NOPE.8XnYkbjP2NVPaI7JA7nkgg',
	          'nyse-quotes' => 'realtime',
	          'authorizations' => {
	                              'options360' => 'false'
	                            },
	          'login-time' => '2010-04-10 18:23:21 EDT',
	          'timeout' => '55',
	          'accounts' => {
	                        'account' => {
	                                     'unified' => 'false',
	                                     'cdi' => 'A000000024055414',
	                                     'segment' => 'AMER',
	                                     'description' => 'DANNE L STAYSKAL',
	                                     'associated-account' => 'true',
	                                     'display-name' => 'dannestayskal',
	                                     'authorizations' => {
	                                                         'advanced-margin' => 'false',
	                                                         'level2' => 'false',
	                                                         'streamer' => 'true',
	                                                         'option-trading' => 'none',
	                                                         'margin-trading' => 'false',
	                                                         'apex' => 'false',
	                                                         'streaming-news' => 'false',
	                                                         'stock-trading' => 'true'
	                                                       },
	                                     'preferences' => {
	                                                      'stock-direct-routing' => 'false',
	                                                      'option-direct-routing' => 'false',
	                                                      'express-trading' => 'false'
	                                                    },
	                                     'account-id' => '757415492',
	                                     'company' => 'AMER'
	                                   }
	                      },
	          'exchange-status' => 'non-professional',
	          'amex-quotes' => 'realtime'
	        };
	
Returns on failure: undef

=cut
sub login {
	my ($self) = @_;
	
	$self->{user_agent}->cookie_jar->clear();
	$self->{user_agent}->cookie_jar->save();
	
	foreach my $key (qw/userid password source version/) {
		unless ($self->{config}->{$key}) {
			print "Cannot log in unless $key is set in config/bridges/ameritrade.yml\n";
			return;
		}
	}
	my $uri = "https://apis.tdameritrade.com/apps/100/LogIn?".
			  "source=$self->{config}->{source}&".
			  "version=$self->{config}->{version}";
	my $response = $self->http_post($uri, $self->{config});

	return unless $response->is_success();
	my $status = XMLin($response->content());
		
	if ($status->{result} eq 'OK') {
		
		$self->save_cookies();
		$self->{session} = $status->{'xml-log-in'};
		return $self->{session};
		
	} elsif ($status->{result} eq 'FAIL') {
		
		print $status->{error}."\n";
		return;
		
	}
	
}


=item C<logout>

Logs out of TD Ameritrade API

Takes: $self

Returns: 1 or undef

=cut
sub logout {
	my ($self) = @_;
	
	unless ($self->{config}->{source}) {
		print "Cannot log out unless source is set in config/bridges/ameritrade.yml\n";
		return;
	}

	my $uri = "https://apis.tdameritrade.com/apps/100/LogOut?".
			  "source=$self->{config}->{source}";
	my $response = $self->http_post($uri);

	return unless $response->is_success();
	my $status = XMLin($response->content());
		
	if ($status->{result} eq 'LoggedOut') {
		
		$self->{user_agent}->cookie_jar->clear();
		undef $self->{session};
		return 1;
		
	} else {
		
		print "Could not log out\n";
		return;
		
	}	
}


=item C<get_quote>

Gets a quote for a specified symbol or group of symbols

Takes: $self, @symbols -- up to 35 stock, option, index, or mutual fund symbols.

Returns on success: $quote_data, which looks something like --

	$VAR1 = {
	          'quote-list' => {
	                          'quote' => {
	                                     'year-low' => '115.76',
	                                     'year-high' => '242.15',
	                                     'bid' => '242.09',
	                                     'high' => '242.15',
	                                     'close' => '239.95',
	                                     'bid-ask-size' => '200X800',
	                                     'low' => '240.46',
	                                     'error' => {},
	                                     'last-trade-date' => '2010-04-09 16:00:10 EDT',
	                                     'symbol' => 'AAPL',
	                                     'volume' => '11922365',
	                                     'change' => '1.84',
	                                     'last' => '241.79',
	                                     'description' => 'APPLE INC COM',
	                                     'ask' => '242.10',
	                                     'open' => '241.43',
	                                     'real-time' => 'true',
	                                     'change-percent' => '0.77%',
	                                     'last-trade-size' => '300',
	                                     'asset-type' => 'E',
	                                     'exchange' => 'NASDAQ'
	                                   },
	                          'error' => {}
	                        },
	          'result' => 'OK'
	        };

Returns on failure: undef.

Note: Options require a + and indices require a $ as the first character.

=cut
sub get_quote {
	my ($self, @symbols) = @_;
	
	my $uri = "https://apis.tdameritrade.com/apps/100/Quote?".
			  "source=$self->{config}->{source}&".
			  "symbol=".join(',',@symbols);
	my $response = $self->http_get($uri);

	return unless $response->is_success();
	my $status = XMLin($response->content());
		
	if ($status->{result} eq 'OK') {
		
		return $status;
		
	} elsif ($status->{result} eq 'Fail') {
		
		print "$status->{error}\n";
		return;
		
	}
}


=item C<lookup_symbol_for>

Looks up symbol names for stocks, options, indices, or mutual funds

Takes: $self, $search_string.

Returns on success: $symbol_results, which looks something like --

	$VAR1 = {
	          'symbol-lookup-result' => {
	                                    'search-string' => 'Southwest',
	                                    'symbol-result' => [
	                                                       {
	                                                         'symbol' => 'LUV',
	                                                         'description' => 'SOUTHWEST AIRLS CO COM'
	                                                       },
	                                                       {
	                                                         'symbol' => 'OKSB',
	                                                         'description' => 'SOUTHWEST BANCORP INC OKLA COM'
	                                                       },
	                                                       {
	                                                         'symbol' => 'OKSBP',
	                                                         'description' => 'SOUTHWEST CAP TR II GTD TR PFD SECS'
	                                                       }
	                                                     ],
	                                    'error' => {}
	                                  },
	          'result' => 'OK'
	        };
	

Returns on failure: undef.

Note: Options will have a + and indices will have a $ as the first character.

=cut
sub lookup_symbol_for {
	my ($self, $search_string) = @_;
	
	my $uri = "https://apis.tdameritrade.com/apps/100/SymbolLookup?".
			  "source=$self->{config}->{source}&".
			  "matchstring=$search_string";
	my $response = $self->http_get($uri);

	return unless $response->is_success();
	my $status = XMLin($response->content());
		
	if ($status->{result} eq 'OK') {
		
		return $status;
		
	} elsif ($status->{result} eq 'Fail') {
		
		print "$status->{error}\n";
		return;
		
	}
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut
1;
__END__
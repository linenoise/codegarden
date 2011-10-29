package Tinhorn::Model::Instrument;

use strict;

=head1 NAME

Tinhorn::Model::Instrument - The Tinhorn Model for financial instruments (stocks, funds, currencies, etc)

=head1 SYNOPSIS

See L<Class::DBI>.

=head1 DESCRIPTION

See L<Class::DBI>.

=cut

use base 'Tinhorn::Model';

Tinhorn::Model::Instrument->table('instrument');
Tinhorn::Model::Instrument->columns(All => qw/id name instrument_type exchange_id currency_id symbol description home_url wikipedia_url dukascopy_code/);
Tinhorn::Model::Instrument->has_a(exchange_id => 'Tinhorn::Model::Exchange');
Tinhorn::Model::Instrument->has_a(currency_id => 'Tinhorn::Model::Currency');
Tinhorn::Model::Instrument->has_many(market_rates => 'Tinhorn::Model::MarketRate');

Tinhorn::Model::Instrument->set_sql(market_rate_count => qq{
	SELECT count(id) 
	FROM __TABLE__ 
	WHERE id = __IDENTIFIER__;
});

sub google_finance_url {
	my ($self) = @_;
	if ($self->exchange_id && $self->exchange_id->google_symbol) {
		return 'http://www.google.com/finance?q='.$self->exchange_id->google_symbol . ':' . $self->symbol;
	} else {
		### We don't know its exchange, or we don't know that exchange's GF symbol.
		return;
	}
}


sub reuters_finance_url {
	my ($self) = @_;
	if ($self->exchange_id && $self->exchange_id->reuters_symbol) {
		return 'http://www.reuters.com/finance/stocks/overview?symbol='.
			   $self->symbol.'.'.$self->exchange_id->reuters_symbol;
	} else {
		### We don't know its exchange, or we don't know that exchange's Reuters symbol.
		return;
	}
}


sub yahoo_finance_url {
	my ($self) = @_;
	if ($self->exchange_id) {
		### N.B. Yahoo Finance assumes NYSE, NASDAQ, or Tokyo for symbols with no suffix.
		my $no_suffix = $self->exchange_id->symbol eq 'NYSE' || 
						$self->exchange_id->symbol eq 'NASDAQ' || 
						$self->exchange_id->symbol eq 'TSE';
		if ($no_suffix) {
			return 'http://finance.yahoo.com/q?s='.
				   $self->symbol;

		} elsif ($self->exchange_id->yahoo_symbol) {
			return 'http://finance.yahoo.com/q?s='.
			       $self->symbol.'.'.$self->exchange_id->yahoo_symbol;
			
		} else {
			### We know the exchange, but yahoo doesn't have a symbol for it.
			return;
		}		
	} else {
		### We don't know which exchange it's listed on
		return;
	}
}


=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
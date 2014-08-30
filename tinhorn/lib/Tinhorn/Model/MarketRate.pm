package Tinhorn::Model::MarketRate;

use strict;

=head1 NAME

Tinhorn::Model::MarketRate - The Tinhorn Model for market rates (quotes or exchange rates)

=head1 SYNOPSIS

See L<Class::DBI>.

=head1 DESCRIPTION

See L<Class::DBI>.

=cut

use base 'Tinhorn::Model';

Tinhorn::Model::MarketRate->table('market_rate');
Tinhorn::Model::MarketRate->columns(All => qw/id instrument_id open high low close volume quoted_at quoted_on interval_code/);
Tinhorn::Model::MarketRate->has_a(instrument_id => 'Tinhorn::Model::Instrument');

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
package Tinhorn::Model::Exchange;

use strict;

=head1 NAME

Tinhorn::Model::Exchange - The Tinhorn Model for Exchanges

=head1 SYNOPSIS

See L<Class::DBI>.

=head1 DESCRIPTION

See L<Class::DBI>.

=cut

use base 'Tinhorn::Model';

Tinhorn::Model::Exchange->table('exchange');
Tinhorn::Model::Exchange->columns(All => qw/id name country_id symbol google_symbol reuters_symbol yahoo_symbol/);
Tinhorn::Model::Exchange->has_a(country_id => 'Tinhorn::Model::Country');

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
package Tinhorn::Model::Currency;

use strict;

=head1 NAME

Tinhorn::Model::Currency - The Tinhorn Model for Currencies

=head1 SYNOPSIS

See L<Class::DBI>.

=head1 DESCRIPTION

See L<Class::DBI>.

=cut

use base 'Tinhorn::Model';

Tinhorn::Model::Currency->table('currency');
Tinhorn::Model::Currency->columns(All => qw/id name code exponent/);
Tinhorn::Model::Currency->has_many(countries => 'Tinhorn::Model::Country');

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
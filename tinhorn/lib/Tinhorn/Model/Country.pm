package Tinhorn::Model::Country;

use strict;

=head1 NAME

Tinhorn::Model::Country - The Tinhorn Model for Countries

=head1 SYNOPSIS

See L<Class::DBI>.

=head1 DESCRIPTION

See L<Class::DBI>.

=cut

use base 'Tinhorn::Model';

Tinhorn::Model::Country->table('country');
Tinhorn::Model::Country->columns(All => qw/id name code currency_id/);
Tinhorn::Model::Country->has_a(currency_id => 'Tinhorn::Model::Currency');

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
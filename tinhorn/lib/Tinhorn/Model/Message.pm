package Tinhorn::Model::Message;

use strict;

=head1 NAME

Tinhorn::Model::Message - The Tinhorn Model for Messages

=head1 SYNOPSIS

See L<Class::DBI>.

=head1 DESCRIPTION

See L<Class::DBI>.

=cut

use base 'Tinhorn::Model';

Tinhorn::Model::Message->table('message');
Tinhorn::Model::Message->columns(All => qw/id logged_at contents/);

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
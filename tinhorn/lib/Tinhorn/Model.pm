package Tinhorn::Model;

use strict;

=head1 NAME

Tinhorn::Model - The Tinhorn Model superclass

=head1 SYNOPSIS

	package Tinhorn::Model::Currency;
	use base 'Tinhorn::Model';
	Tinhorn::Model::Currency->table('currency');
	Tinhorn::Model::Currency->columns(All => qw/id name code exponent/);
	Tinhorn::Model::Currency->has_many(countries => 'Tinhorn::Model::Country');
	
=head1 DESCRIPTION

This is just a very basic subclass of L<Class::DBI>

=over 4

=back

=cut

use YAML qw/LoadFile/;
use base 'Class::DBI';

sub BEGIN {
	my $auth = LoadFile('conf/relational/auth.yml') || die "Can't load conf/relational/auth.yml";
	Tinhorn::Model->connection("dbi:$auth->{adapter}:$auth->{database}", $auth->{username}, $auth->{password});
}

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
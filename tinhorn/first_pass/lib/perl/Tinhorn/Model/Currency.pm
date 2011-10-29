package Tinhorn::Model::Currency;

use strict;


=head1 NAME

Tinhorn::Model::Currency - The Tinhorn Currency model

=head1 SYNOPSIS

	use Tinhorn::Model::Currency;
	
	### Create
	my $currency = new Tinhorn::Model::Currency;
	$currency->{name} = 'foo';
	$currency->save();

	### Read
	my $currency2 = Tinhorn::Model::Currency::get({name => 'bar'});
	
	### Update
	$currency2->{name} = 'baz';
	$currency2->save();
	
	### Delete
	$currency->delete();
	
=head1 DESCRIPTION

This is the Tinhorn Currency model.  It handles data persistence for currency objects.  The following methods are provided by L<Tinhorn::Model::_Sqlite> and are documented there:

=over 4

=item C<new> - class constructor

=item C<get> - gets a single object from the database

=item C<find> - retrieves multiple objects from the database

=item C<save> - saves a current object to the database

=item C<delete> - removes an object from the database

=back

=cut

use base qw/Tinhorn::Model::_Sqlite/;

### Declare our metadata, get, and find procedures
sub _meta {
	return {
		'package' => __PACKAGE__,
		'table'    => 'currencies',
		'signature'   => ['code'],
	}
};
sub get  { return Tinhorn::Model::_Sqlite::get(_meta(),@_) }
sub find { return Tinhorn::Model::_Sqlite::find(_meta(),@_) }
sub all  { return Tinhorn::Model::_Sqlite::all(_meta(),@_) }

=head1 METHODS

These methods are unique to the Tinhorn::Model::Currency objects, and are not necessarily available to other modeled objects in the Tinhorn system.

=over 4



=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
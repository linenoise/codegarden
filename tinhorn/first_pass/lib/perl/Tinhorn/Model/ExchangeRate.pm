package Tinhorn::Model::ExchangeRate;

use strict;


=head1 NAME

Tinhorn::Model::ExchangeRate - The Tinhorn ExchangeRate model

=head1 SYNOPSIS

	use Tinhorn::Model::Currency;

	### Create
	my $exchange_rate = new Tinhorn::Model::ExchangeRate;
	$exchange_rate->{name} = 'foo';
	$exchange_rate->save();

	### Read
	my $exchange_rate2 = Tinhorn::Model::ExchangeRate::get({name => 'bar'});

	### Update
	$exchange_rate2->{name} = 'baz';
	$exchange_rate2->save();

	### Delete
	$exchange_rate->delete();
	
=head1 DESCRIPTION

This is the Tinhorn ExchangeRate model.  It handles data persistence for exchange_rate objects.  The following methods are provided by L<Tinhorn::Model::_Sqlite> and are documented there:

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
		'table'    => 'exchange_rates',
		'signature'   => ['base_currency', 'quote_currency', 'quote_date'],
	}
};
sub get  { return Tinhorn::Model::_Sqlite::get(_meta(),@_) }
sub find { return Tinhorn::Model::_Sqlite::find(_meta(),@_) }
sub all  { return Tinhorn::Model::_Sqlite::all(_meta(),@_) }

=head1 METHODS

These methods are unique to the Tinhorn::Model::ExchangeRate objects, and are not necessarily available to other modeled objects in the Tinhorn system.

=over 4



=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
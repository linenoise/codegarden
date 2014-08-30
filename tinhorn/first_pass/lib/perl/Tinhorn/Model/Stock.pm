package Tinhorn::Model::Stock;

use strict;


=head1 NAME

Tinhorn::Model::Stock - The Tinhorn Stock model

=head1 SYNOPSIS

	use Tinhorn::Model::Stock;
	
	### Create
	my $apple = new Tinhorn::Model::Stock;
	$apple->{exchange} = 'NASDAQ';
	$apple->{symbol} = 'AAPL';
	$apple->{price} = 241.79;
	$apple->save();

	### Read
	my $google = Tinhorn::Model::Stock::get({symbol => 'GOOG', exchange => 'NASDAQ'});
	my @nyse = Tinhorn::Model::Stock::find({exchange => 'NASDAQ'});
	
	### Update
	$apple->{price} = 240.03;
	$apple->save();
	
	### Delete
	$google->delete();
	
=head1 DESCRIPTION

This is the Tinhorn Stock model.  It handles data persistence for stock objects.  The following methods are provided by L<Tinhorn::Model::_Sqlite> and are documented there:

=over 4

=item C<new> - class constructor

=item C<get> - gets a single object from the database

=item C<find> - retrieves multiple objects from the database

=item C<save> - saves a current object to the database

=item C<delete> - removes an object from the database

=back

=cut

use base qw/Tinhorn::Model::_Sqlite/;

### Declare our metadata
our $meta = {
	'package' => __PACKAGE__,
	'table'    => 'stocks',
	'signature'   => ['exchange', 'symbol'],
};
sub get  { return Tinhorn::Model::_Sqlite::get(_meta(),@_) }
sub find { return Tinhorn::Model::_Sqlite::find(_meta(),@_) }
sub all  { return Tinhorn::Model::_Sqlite::all(_meta(),@_) }


=head1 METHODS

These methods are unique to the Tinhorn::Model::Stock objects, and are not necessarily available to other modeled objects in the Tinhorn system.

=over 4



=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
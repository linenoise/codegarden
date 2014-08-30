package Tinhorn::Model::_Sqlite;

use strict;

=head1 NAME

Tinhorn::Model::_Sqlite - The Tinhorn SQLite model superclass

=head1 SYNOPSIS

	### Use this through subclasses - not directly.
	use base qw/Tinhorn::Model::Sqlite/;
	
=head1 DESCRIPTION

This is the Tinhorn Sqlite model superclass.  It handles search (functions) and CRUD (methods) for sqlite-based model objects.

=head1 FUNCTIONS

These are functions that should be called directly from the class (Tinhorn::Model::Something::get) rather than from any object.  They are the entry-points to working with Tinhorn-modelled objects.

=over 4

=cut

use DBI;


=item C<_get_database_handle>

Gets the Tinhorn Sqlite database handle

Takes: nothing

Returns: $dbh

=cut
sub _get_database_handle {
	
  return DBI->connect("dbi:SQLite:dbname=data/relational/tinhorn.sqlite","","");
	
}


=item C<new>

Creates and returns a new data object under this model.  Does not save.

Takes: C<$class>, C<$args> -- a hash ref containing anything that should go into the new object

Returns: C<$object>

=cut

sub new {
	my ($class, $args) = @_;
	
	my $self = {};
	$self->{$_} = $args->{$_} foreach keys %$args;
	bless $self, $class;
	
	return $self;
}


=item C<get>

Retrieves a single object from SQLite, knowing a unique vector of information about it.

Takes: C<$meta>, C<$properties>, a hash ref containing key-value pairs to be looked up in the base data table

Returns: C<$object> on success, undef on failure

=cut
sub get {
	my ($meta, $properties) = @_;
	
	my $dbh = _get_database_handle();

	### See if there's already something with this signature in the DB
	my $check_sql = "SELECT * from ".$meta->{table}." where ".
		join(' AND ',map({"$_ = '$properties->{$_}'"} @{$meta->{signature}})).';';
	my $existing_data = $dbh->selectrow_hashref($check_sql);
	
	if ($existing_data) {
		return new($meta->{package}, $existing_data);
	} else {
		return;
	}
}


=item C<find>

Retrieves an array of objects from SQLite, using specified search parameters.

Takes: C<$meta>, C<$properties>, a hash ref containing key-value pairs to be searched

Returns: C<@objects> on success, undef on failure

=cut
sub find {
	my ($meta, $properties) = @_;
	
	my $dbh = _get_database_handle();

	my $find_sql = "SELECT * from ".$meta->{table}." where ".
		join(' AND ',map({"$_ = '$properties->{$_}'"} keys(%$properties))).';';

	my @objects;

	my $sth = $dbh->prepare($find_sql);
	if ($sth->execute()) {
		while (my $row = $sth->fetchrow_hashref) {
			push @objects, new($meta->{package}, $row);
		}
	} else {
		print "Couldn't prepare $find_sql.\n$DBI::errstr\n";
		return;
	}

	if (scalar(@objects)) {
		return @objects
	} else {
		return;
	}
}


=item C<all>

Retrieves an array of all objects from SQLite.

Takes: C<$meta>

Returns: C<@objects> on success, undef on failure

=cut
sub all {
	my ($meta) = @_;
	
	my $dbh = _get_database_handle();

	### See if there's already something with this signature in the DB
	my $find_sql = "SELECT * from ".$meta->{table}.';';

	my @objects;

	my $sth = $dbh->prepare($find_sql);
	if ($sth->execute()) {
		while (my $row = $sth->fetchrow_hashref) {
			push @objects, new($meta->{package}, $row);
		}
	} else {
		print "Couldn't prepare $find_sql.\n$DBI::errstr\n";
		return;
	}

	if (scalar(@objects)) {
		return @objects
	} else {
		return;
	}
}


=back

=head1 METHODS

These are methods to be called on the subclassed objects themselves (e.g. $object->save()) -- not on the class.

=over 4



=item C<save>

Saves the current object

Takes: C<$self>

Returns: C<$self> on success, undef on failure

=cut
sub save {
	my ($self) = @_;
	
	my $dbh = _get_database_handle();
	
	### See if there's already something with this signature in the DB
	my $check_sql = "SELECT count(*) from ".$self->_meta()->{table}." where ".
		join(' AND ',map({"$_ = '$self->{$_}'"} @{$self->_meta()->{signature}})).';';
	my $existing_record = $dbh->selectrow_array($check_sql);
	
	if ($existing_record) {
		### Update
		my $update_sql = 'UPDATE '.$self->_meta()->{table}.' SET '.
			join(', ', map({"$_ = '$self->{$_}'"} sort(grep /^[^_]/, keys(%$self)))).' WHERE '.
			join(' AND ',map({"$_ = '$self->{$_}'"} @{$self->_meta()->{signature}}));
			
		if ($dbh->do($update_sql)) {
			return $self;			
		} else {
			return;
		}
		
	} else {
		### Insert
		my $insert_sql = 'INSERT INTO '.$self->_meta()->{table}.' ( '.
			join(', ', sort(grep /^[^_]/, keys(%$self))) . ' ) VALUES ( '.
			join(', ', map({"'$self->{$_}'"} sort(grep /^[^_]/, keys(%$self)))).' )';
		if ($dbh->do($insert_sql)) {
			return $self;			
		} else {
			return;
		}
	}
}


=item C<delete>

Deletes the current object

Takes: C<$self>

Returns: 1 on success, undef on failure

=cut
sub delete {
	my ($self) = @_;
	
	my $dbh = _get_database_handle();
	
	my $delete_sql = 'DELETE FROM '.$self->_meta()->{table}.' WHERE '.
		join(' AND ',map({"$_ = '$self->{$_}'"} @{$self->_meta()->{signature}}));
		
	if ($dbh->do($delete_sql)) {
		undef $self;
		return 1;			
	} else {
		return;
	}
	
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
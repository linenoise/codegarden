package Tinhorn::Controller::Mockups;

use strict;

=head1 NAME

Tinhorn::Controller::Mockups - The Tinhorn Controller for mockup management

=head1 SYNOPSIS

	my $mocker = new Tinhorn::Controller::Mockups;

	### Find the filename for a given URI
	my $filename = $mocker->filename_for($uri);

	### Store an HTTP response to a mockup
	my $status = $mocker->mock($response, $uri);
	
	### Read an HTTP response from a mockup
	my $response = $mocker->read($file);
	
	### Visualize an HTTP response contained in a mockup
	my $string = $mocker->view($file);

=head1 DESCRIPTION

This is the Tinhorn controller for mockup management.  It allows Tinhorn to automatically detect and build any mockups it might have, be they libraries, clients, servers, or other miscellaneous pieces of software we might need.

=cut

use Storable;
use HTTP::Response;
use CGI qw/escape/;


=head1 METHODS

=over 4

=item C<new>

The Mockups Controller constructor

Takes: C<$class>

Returns: C<$self> -- a blessed L<Tinhorn::Controller::Mockups> object

=cut
sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;
	
	return $self;
}


=item C<filename_for>

Returns the filename for a given URI

Takes: $self, $uri

Returns: $filename

=cut
sub filename_for {
	my ($self, $uri) = @_;

	return 'data/mockups/http/'.escape($uri);
}


=item C<mock>

Store an HTTP response to a mockup file

Takes: $self, $response, and $uri

Returns: 1 on success, 0 on failure

=cut
sub mock {
	my ($self, $response, $uri) = @_;
	
	my $filename = $self->filename_for($uri);
	unless ( -f $filename ) {
		store $response, $filename;
	}
	
}


=item C<read>

Retrieves an HTTP response from a mockup file

Takes: $self, $file

Returns: $response or nothing

=cut
sub read {
	my ($self, $file) = @_;
	
	if ( -f $file ) {
		return retrieve $file;
	} else {
		return;
	}
	
}


=item C<view>

Returns a printable ASCII representation of the HTTP response contained in a file

Takes: $self, $response, and $file

Returns: 1 on success, 0 on failure

=cut
sub view {
	my ($self, $file) = @_;
	
	my $response = retrieve $file;

	if (ref($response) eq 'HTTP::Response') {
		return $response->as_string();
	} else {
		return "Object serialized at $file is not an HTTP::Response.\n";
	}
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
package Tinhorn::App::Webserver::Router;

use strict;

=head1 NAME

Tinhorn::App::Webserver::Router - The Tinhorn Webserver application's Router

=head1 SYNOPSIS

	return Tinhorn::App::Webserver->new(8080)->run();

=head1 DESCRIPTION

This is the Tinhorn Webserver application.  It provides Tinhorn's HTTP interface..

=head1 TODO

=over 4

=item Finish page-level caching

=item Implement caching of partials

=back

=head1 METHODS

=over 4

=cut

use Tinhorn::View::Bread;
use Tinhorn::View::Currencies;
use Tinhorn::View::Home;
use Tinhorn::View::Status;
use Tinhorn::View::Test;
use Tinhorn::View::Instrument;

our %routing_table = ();


=item C<new>

The Tinhorn web server router class constructor

Takes: C<$class>

Returns: C<$self> -- a shiny, new Tinhorn::App::Webserver::Router

=cut
sub new {
	my ($class) = @_;
	
	my $self = {};
	load_routes_from(%Tinhorn::View::Bread::routes);
	load_routes_from(%Tinhorn::View::Currencies::routes);
	load_routes_from(%Tinhorn::View::Home::routes);
	load_routes_from(%Tinhorn::View::Status::routes);
	load_routes_from(%Tinhorn::View::Test::routes);
	load_routes_from(%Tinhorn::View::Instrument::routes);
	bless $self, $class;
	
	return $self;
}


=item C<load_routes_from>

Loads routes from a given view module into the main routing table

Takes: C<$routes>

Returns: 1;

=cut
sub load_routes_from {
	my (%routes) = @_;
	
	foreach my $path (keys %routes) {
		$routing_table{$path} = $routes{$path};
	}
	
	return 1;
}


=item C<knows_about>

Returns whether this router can route a given path

Takes: C<$self>, C<$path>

Returns: 1 on success, 0 on failure

=cut
sub knows_about {
	my ($self, $path) = @_;

	return 1 if $routing_table{$path};
	
	return 0;
}


=item C<process>

Runs code at a given route, returns response

Takes: C<$self>, C<$path>, $<cgi>

Returns: 1 on success, 0 on failure

=cut
sub process {
	my ($self, $path, $cgi) = @_;

	return unless $routing_table{$path};
	
	return $routing_table{$path}->($cgi);
}




=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut
1;
__END__;
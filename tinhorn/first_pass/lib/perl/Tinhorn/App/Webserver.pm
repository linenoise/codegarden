package Tinhorn::App::Webserver;

use strict;

=head1 NAME

Tinhorn::App::Webserver - The Tinhorn Webserver application

=head1 SYNOPSIS

	return Tinhorn::App::Webserver->new(8080)->run();

=head1 DESCRIPTION

This is the Tinhorn Webserver application.  It provides Tinhorn's HTTP interface.

=back

=head1 METHODS

=over 4

=cut

sub BEGIN {
	use Tinhorn::App::Webserver::Dispatcher;
	use Tinhorn::App::Webserver::Router;

	use base qw(HTTP::Server::Simple::CGI);

	$SIG{INT} = sub {
		print "\nInterrupt caught.  Exiting gracefully.\n";
		exit 0;
	};

}


sub new {
	my ($self, @args) = @_;
	
	### Preload dynamic dispatcher
	print "Tinhorn::App::Webserver preloading dispatcher...\n";
	$Tinhorn::App::Webserver::dispatcher = new Tinhorn::App::Webserver::Dispatcher();

	### Preload dynamic router
	print "Tinhorn::App::Webserver preloading router...\n";
	$Tinhorn::App::Webserver::router = new Tinhorn::App::Webserver::Router();

	return $self->SUPER::new(@args);
}

=item C<handle_request>

The Tinhorn web server request handler / router

Takes: C<$self>, C<$cgi>

Returns: C<$http_response> -- whatever the dispatcher sent to the User Agent

=cut
sub handle_request {
	my ($self, $cgi) = @_;
	$Tinhorn::App::Webserver::dispatcher->dispatch($cgi, $Tinhorn::App::Webserver::router);
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
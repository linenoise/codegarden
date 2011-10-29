package Tinhorn::App::Webserver::Dispatcher;

use strict;

=head1 NAME

Tinhorn::App::Webserver::Dispatcher - The Tinhorn Webserver application's Dispatcher

=head1 SYNOPSIS

	### Prepare and cache the dispatcher
	$Tinhorn::App::Webserver::dispatcher = new Tinhorn::App::Webserver::Dispatcher();

	### Dispatch the incoming request
	$Tinhorn::App::Webserver::dispatcher->dispatch($cgi);

=head1 DESCRIPTION

This is the Tinhorn Webserver application's dispatcher.  It matches incoming requests with appropriate resources throughout Tinhorn's code, caches, and file system.

=head1 TODO

=over 4

=item Finish page-level caching

=item Implement caching of partials

=back

=head1 METHODS

=over 4

=cut


use HTTP::Status;
use HTTP::Server::Simple::CGI;
use File::stat;
use List::Util qw/first/;

our %http_errors = (

	### Your problem
	400 => {status => 'Bad Request', message => 'The request your browser sent to the service is malformed. '},
	401 => {status => 'Unauthorized', message => 'You are not authorized to view this content. '},
	402 => {status => 'Payment Required', message => 'Payment is required for this content. '},
	403 => {status => 'Forbidden', message => 'You are not authorized to use this service. '},
	404 => {status => 'Resource Not Found', message => 'The resource you requested could not be found. '},

	### My problem
	500 => {status => 'Internal Server Error', message => 'Something went wrong in the server. '},
	501 => {status => 'Not Implemented', message => 'This feature has not yet been implemeted. '},
	502 => {status => 'Service Unavailable', message => 'The service you\'ve requested is unavailable. '},

);

our %content_types = (
	'htm' => 'text/html',
	'html' => 'text/html',
	'txt' => 'text/plain',
	'css' => 'text/css',
	'js' => 'text/javascript',

	'gif' => 'image/gif',
	'png' => 'image/x-png',
	'jpg' => 'image/jpeg',
	'jpeg' => 'image/jpeg',

	'pdf' => 'application/pdf',
);


=item C<new>

The Tinhorn web server request dispatcher class constructor

Takes: C<$class>

Returns: C<$self> -- a shiny, new Tinhorn::App::Webserver::Dispatcher

=cut
sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;
	
	return $self;
}


=item C<dispatch>

The Tinhorn web server request handler / router

Takes: C<$self>, C<$cgi> -- the currently CGI object, C<$router> -- the current Tinhorn::App::Webserver::Router, C<$template> -- the current Template Toolkit handle

Returns: C<$http_response> -- whatever the dispatcher sent to the User Agent

=cut
sub dispatch {
	my ($self, $cgi, $router, $template) = @_;

	my $path = $cgi->path_info();
	
	### If it's a FLAT FILE, send it down the pipe
	if (-f "public/$path") {
		$self->dispatch_file($cgi, "public/$path");
		
	### If it's a CACHED PAGE (fresh within the last three hours), send that along
	} elsif (-f "tmp/caches/http/$path" && ((time() - stat("tmp/caches/http/$path")->mtime()) < '10800')) {
		$self->dispatch_file($cgi, "tmp/caches/http/$path");

	### Otherwise, if the router knows what to do with it, dispatch that.
    } elsif ($router->knows_about($path)) {
		$self->dispatch_code($router, $cgi, $path);
    
	### Finally, 404.  It didn't work out.
    } else {
		$self->dispatch_error_message($cgi, 404);
	
    }
}


=item C<respond>

The Tinhorn web server response handler

Takes: C<$self>, C<$cgi>, C<$args> -- a hash ref containing:

=over 4

=item C<status> -- the HTTP response status code (200, 404, 500, etc) (mandatory)

=item C<content_type> -- the HTTP response content type (mandatory)

=item C<charset> -- the character set in which this response is encoded (defaults to utf-8 for text/* content)

=item C<expires> -- the cache expiration of this content (optional, e.g. +30s, +10m, now, +3M, +10Y, etc)

=item C<cookie> -- the cookie to send in the HTTP response (optional)

=item C<content> -- the content of the HTTP response (optional, defaults to nothing)

=back

Note: You will need to pass EITHER content OR [ template AND values ].  Contents takes precedence.

Returns: C<$self> -- a blessed L<Tinhorn::Controller::Dependencies> object

=cut
sub respond {
	my ($self, $cgi, $args) = @_;

	### Send the appropriate HTTP response line
	$args->{code} ||= 200;
	print "HTTP/1.0 $args->{code} " . status_message($args->{code}) . "\r\n";
    
	### Determine the character set
	if ($args->{content_type} =~ /^text/ && ! $args->{charset}) {
		$args->{charset} = 'utf-8';
	}

	### Populate the HTTP response header
	my %header = ();
	$header{status} = $args->{code} . ' ' . status_message($args->{code});
	foreach my $field (qw/content_type charset expires cookie/) {
		$header{$field} = $args->{$field} if $args->{$field}
	}

	### Send it all down the pipe
	print $cgi->header(%header),
	      $args->{content};
}


=item C<dispatch_code>

Prepares a code route for dispatch response

Takes: C<$self>, C<$router>, C<$cgi>, C<$file>

Returns: C<$http_response>

=cut
sub dispatch_code {
	my ($self, $router, $cgi, $path) = @_;
	
	return $self->respond($cgi, $router->process($path, $cgi));
	
	return;
}


=item C<dispatch_file>

Prepares a file from the local file system for dispatch response

Takes: C<$self>, C<$cgi>, C<$file>

Returns: C<$http_response>

=cut
sub dispatch_file {
	my ($self, $cgi, $file) = @_;

	my $extension = first {defined($_)} reverse( split( /\./, $file ));

	### Read the file content from the file system
	my $content;
	my $content_type = $content_types{$extension};
	if (-T $file) {

		### It's an ASCII file.
		open('RESOURCE', '<', $file) || 
			return $self->dispatch_error_message(401, "File exists but is not readable."); ### Unauthorized
		$content = join('', <RESOURCE>);
		close('RESOURCE');
		
		### If we couldn't guess the content type from an extension, use text/plain
		$content_type ||= 'text/plain';

	} else {
		
		### It's a binary file.
		open('RESOURCE', '<', $file) || 
			return $self->dispatch_error_message(401, "File exists but is not readable."); ### Unauthorized
		binmode RESOURCE;
		my ($data, $n); 
		while (($n = read RESOURCE, $data, 4) != 0) { 
			$content .= $data;
		} 
		close('RESOURCE');
		
		### If we couldn't guess the content type from an extension, use application/octet-stream
		$content_type ||= 'application/octet-stream';
		
	}
	
	### Respond with the results
	return $self->respond($cgi, {
		status 			=> 200,
		content_type	=> $content_type,
		content 		=> $content,
	});
	
}


=item C<dispatch_error_message>

Dispatches error message response to browser

Takes: C<$self>, C<$cgi>, C<$status_code>, C<$message> (optional)

Returns: C<$http_response>

=cut
sub dispatch_error_message {
	my ($self, $cgi, $status_code, $message) = @_;
	
	unless ($status_code) {
		return $self->dispatch_error_message('500', 'dispatch_error_message called without a status code.');
	}
	unless ($status_code =~ /^\d*$/) {
		return $self->dispatch_error_message('500', 'dispatch_error_message called with malformed status code.');
	}
	unless (ref $http_errors{$status_code} eq 'HASH') {
		return $self->dispatch_error_message('500', 'dispatch_error_message called with unknown status code.');
	}

	my $content = $http_errors{$status_code}->{status}."\n\n".
				   $http_errors{$status_code}->{message}."\n";
	$content .= $message if $message;
	
	### Append help message to 4xx errors
	if (int($status_code / 100) == 4) { 
		$content .= ' Please press the back button on your browser. '.
					 'If you feel you\'ve received this message in error, please contact the support desk.';

	### Append help message to 5xx errors
	} elsif (int($status_code / 100) == 5) {
		$content .= ' We apologize for this.  Please retry your request at a later time. ';
	}
	
	return $self->respond($cgi, {
		status 			=> $status_code,
		content_type	=> 'text/plain',
		content 		=> $content,
	});

}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
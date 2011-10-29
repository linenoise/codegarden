package Tinhorn::Bridge::_HTTP;

use strict;

=head1 NAME

Tinhorn::Bridge::_HTTP - The Tinhorn HTTP-style bridge superclass

=head1 SYNOPSIS

	package Tinhorn::Bridge::Something;
	use base qw/Tinhorn::Bridge::_HTTP/;

=head1 DESCRIPTION

This is the Tinhorn HTTP bridge superclass.  It provides basic HTTP mechanisms used across most bridges.

=cut

use LWP;
use List::Util qw/first/;
use HTTP::Cookies;
use HTTP::Request;
use CGI qw/escape/;
use YAML qw/LoadFile/;

use Tinhorn::Controller::Mockups;


=item C<new>

Superclass constructor for Tinhorn::Bridge::_HTTP objects

Takes: C<$class>

Returns: $self -- a blessed SUBCLASS member

=cut
sub new{
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;
	
	my $shortname = lc(first {defined $_} reverse(split(/::/,$class)));
	
	### Build the user agent
	my $user_agent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.3) '.
					 'Gecko/20100401 Firefox/3.6.3';
	$self->{user_agent} = LWP::UserAgent->new();
	$self->{user_agent}->agent($user_agent);
	
	### Figure out where we're stashing the cookies
	my $cookie_jar_path = 'tmp/cookies/'.$shortname.'.txt';	
	my $cookie_jar = HTTP::Cookies->new(
		'file' => $cookie_jar_path,
		autosave => 1,
	);
	$self->{user_agent}->cookie_jar($cookie_jar);

	### Pull up any special configuration variables
	my $config_file = 'conf/bridges/'.$shortname.'.yml';
	if (-f $config_file) {
		$self->{config} = LoadFile($config_file);
	}

	### Spin up and store the mockup manager
	$self->{mocker} = new Tinhorn::Controller::Mockups;

	return $self;
}


=item C<http_get>

Performs an HTTP GET operation, returns HTTP::Response.

Takes: C<$self>, C<$uri>, C<$args>, containing optionally 'no_mockup', which will prevent generation of a mockup

Returns: $response

=cut
sub http_get {
	my ($self, $uri, $args) = @_;
	
	my $request = HTTP::Request->new('GET');
	$request->uri($uri);
	$self->{user_agent}->{cookie_jar}->add_cookie_header( $request );

#	print "REQUEST: \n";
#	print ($request->as_string()."\n");

	my $response = $self->{user_agent}->request($request);	

#	print "RESPONSE: \n";
#	print ($response->as_string()."\n");

	$self->{mocker}->mock($response, $uri) unless $args && ref $args eq 'HASH' && $args->{no_mockup};
	
	return $response;
		
}


=item C<http_post>

Performs an HTTP POST operation, returns HTTP::Response.

Takes: C<$self>, C<$uri>, C<$params>, C<$args>, containing optionally 'no_mockup', which will prevent generation of a mockup

Returns: $response

=cut
sub http_post {
	my ($self, $uri, $params, $args) = @_;
	
	my $request = HTTP::Request->new('POST');
	$request->uri($uri);
	$self->{user_agent}->{cookie_jar}->add_cookie_header( $request );

	if(scalar(keys(%$params))) {
		$request->content_type('application/x-www-form-urlencoded');
		my $param_string = join('&',map({escape($_).'='.escape($params->{$_})} keys(%$params)));
	    $request->content("$param_string");
	}

#	print "REQUEST: \n";
#	print ($request->as_string()."\n");

	my $response = $self->{user_agent}->request($request);	

#	print "RESPONSE: \n";
#	print ($response->as_string()."\n");

	$self->{mocker}->mock($response, $uri) unless $args && ref $args eq 'HASH' && $args->{no_mockup};
	
	return $response;
		
}


=item C<save_cookies>

Manually saves cookie jar to a file (since HTTP::Cookies can't seem to manage that responsibly)

Takes: C<$self>

Returns: 1 or undef

=cut
sub save_cookies {
	my ($self) = @_;
	
	return unless $self->{user_agent};
	return unless $self->{user_agent}->cookie_jar;

	my $filename = $self->{user_agent}->cookie_jar->{file};
	my $contents = $self->{user_agent}->cookie_jar->as_string();
	
	open('COOKIE_JAR', '>', $filename) || return;
	print COOKIE_JAR "#LWP-Cookies-1.0\n$contents";
	close('COOKIE_JAR');
	
	return 1;

}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut
1;
__END__
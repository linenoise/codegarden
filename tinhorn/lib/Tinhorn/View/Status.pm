package Tinhorn::View::Status;

use strict;

=head1 NAME

Tinhorn::View::Status - The Tinhorn /status view

=head1 SYNOPSIS

	### Meanwhile, back in Tinhorn::App::Webserver::Router
	use Tinhorn::View::Status;
	load_routes_from(%Tinhorn::View::Status::routes);
	
=head1 DESCRIPTION

This module shows basic status information

=head1 METHODS

=over 4

=cut

use Tinhorn::View qw/render/;
use base qw(Tinhorn::View);

our %routes = (
	'/status' => *default,
);


=item C<default>

/status - The status summary page.

=cut
sub default {
	my ($cgi) = @_;
	
	my $content = render('status.tt',{
	    status  => __PACKAGE__,
	});
		
	### Respond with the results
	return {
		status 			=> 200,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
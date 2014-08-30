package Tinhorn::View::Home;

use strict;

=head1 NAME

Tinhorn::View::Home - The Tinhorn /home view

=head1 SYNOPSIS

	### Meanwhile, back in Tinhorn::App::Webserver::Router
	use Tinhorn::View::Home;
	load_routes_from(%Tinhorn::View::Home::routes);
	
=head1 DESCRIPTION

This module shows basic home information

=head1 METHODS

=over 4

=cut

use Tinhorn::View qw/render/;
use base qw(Tinhorn::View);

our %routes = (
	'/' => *default,
);


=item C<default>

/ - The home page.

=cut
sub default {
	my ($cgi) = @_;
	
	my $content = render('home.tt',{});
		
	### Respond with the results
	return {
		home 			=> 200,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
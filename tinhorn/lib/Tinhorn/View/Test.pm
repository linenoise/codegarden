package Tinhorn::View::Test;

use strict;

=head1 NAME

Tinhorn::View::Test - The Tinhorn /test view

=head1 SYNOPSIS

	### Meanwhile, back in Tinhorn::App::Webserver::Router
	use Tinhorn::View::Test;
	load_routes_from(%Tinhorn::View::Test::routes);
	
=head1 DESCRIPTION

This module shows basic test information

=head1 METHODS

=over 4

=cut

use Tinhorn::View qw/render/;
use base qw(Tinhorn::View);

our %routes = (
	'/test' => *default,
	'/test/typography' => *typography,
);


=item C<default>

/test - The test summary page.

=cut
sub default {
	my ($cgi) = @_;
	
	my $content = render('test/default.tt',{});
		
	### Respond with the results
	return {
		test 			=> 200,
		content_type	=> 'text/html',
		content 		=> $content,
	};
}


=item C<typography>

/test - The test summary page.

=cut
sub typography {
	my ($cgi) = @_;
	
	my $content = render('test/typography.tt',{});
		
	### Respond with the results
	return {
		test 			=> 200,
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
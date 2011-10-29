package Tinhorn::View;

use strict;

=head1 NAME

Tinhorn::App::View - The Tinhorn View superclass

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 TODO

=over 4

=back

=head1 METHODS

=over 4

=cut

use Template;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(render);


=item C<render>

Renders a set of variables into a template

Takes: C<$template>, C<$vars>

Returns: $content -- the rendered document

=cut
sub render{
	my ($template, $vars) = @_;
	
	$Tinhorn::View::template ||= Template->new({
		INCLUDE_PATH => 'templates',
		INTERPOLATE  => 0,
		POST_CHOMP   => 0,
		EVAL_PERL    => 0,
	});

	my $content = '';
	$Tinhorn::View::template->process($template, $vars, \$content);
	$content = $Tinhorn::View::template->error() if $Tinhorn::View::template->error();
	
	return $content;
}

=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
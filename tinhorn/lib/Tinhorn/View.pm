package Tinhorn::View;

use strict;

=head1 NAME

Tinhorn::View - The Tinhorn View superclass

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
our @EXPORT_OK = qw(render clean_alpha clean_alphanumeric clean_numeric);


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

	$vars->{username} ||= 'danne';
	
	$vars->{systems}->{harvester_pid} = `cat tmp/harvester.pid`;
	$vars->{systems}->{webserver_pid} = `cat tmp/webserver.pid`;

	my $content = '';
	$Tinhorn::View::template->process($template, $vars, \$content);
	$content = $Tinhorn::View::template->error() if $Tinhorn::View::template->error();
	
	return $content;
}


=item C<clean_alphanumeric>

Cleans something that should be solely alphanumeric input

Takes $string, returns $string

=cut
sub clean_alphanumeric {
	my ($string) = @_;
	$string =~ s/\W//g;
	return $string;
}


=item C<clean_alpha>

Cleans something that should be solely alphabetic input

Takes $string, returns $string

=cut
sub clean_alpha {
	my ($string) = @_;
	$string =~ s/[[:^alpha:]]//g;
	return $string;
}

=item C<clean_numeric>

Cleans something that should be solely numeric input

Takes $string, returns $string

=cut
sub clean_numeric{
	my ($string) = @_;
	$string =~ s/\D//g;
	return $string;
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
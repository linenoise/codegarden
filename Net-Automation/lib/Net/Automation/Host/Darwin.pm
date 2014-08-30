package Net::Automation::Host::Darwin;

use version;
our $VERSION = qv(0.01);
use base qw(Net::Automation::Host);

=head1 NAME

Net::Automation::Host::Darwin - Models a Darwin (Mac OS X, generally) server

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 PUBLIC METHODS

=cut

use strict;


=head2 new

C<new> takes this class followed by named arguments:

=over

=item hostname

(required) the DNS name of the host in question

=back

=cut

sub new {
	my ($class, $args) = @_;
	
	my $self = $class->SUPER::new( $args );
	$self->{hostname} = $args->{hostname};
	bless $self, $class;

	return $self;
}


=head1 PRIVATE METHODS

=head2 _scp_command

C<_scp_command> constructs an instance of the OpenSSH scp(1) command

Takes $self and a hash reference of arguments:

=cut

sub _scp_command {
	my ($self, $args) = @_;
	
	my $darwin_option = '';
	if (defined $args && ref $args eq 'HASH' && defined $args->{flags} && ref $args->{flags} eq 'ARRAY' && grep /preserve_extended/, @{$args->{flags}}) {
		$darwin_option = ' -E';
		my ($position) = grep {$args->{flags}->[$_] eq 'preserve_extended' } 0 .. scalar(@{$args->{flags}})-1;
		delete $args->{flags}->[$position];
	}
	
	return '/usr/bin/scp' . $darwin_option . 
		   $self->{service}->{'Net::Automation::Service::OpenSSH'}->_scp_command_options($args);
}

=head1 AUTHORS

This module written by Danne Stayskal <danne@stayskal.com>.

=head1 COPYRIGHT

This module is Copyright (c) 2009 by Danne Stayskal <danne@stayskal.com>.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut
1;
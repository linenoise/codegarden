package Net::Automation::Service::Apache2;

use version;
our $VERSION = qv(0.01);

=head1 NAME

Net::Automation::Service::Apache2 - Models the behavior of Apache 2.x

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

=cut

use strict;

=head2 new

C<new> takes this class followed by optional named arguments:

=over

=item named_argument

Description of that named argument

=back

For example:

	example_use_of_this_method()

=cut

sub new {
	my ($class, $args) = @_;
	
	my $self = {};
	foreach my $key (qw/http_port https_port/) {
		$self->{$key} = $args->{$key} if $args && $args->{$key};
	}
	$self->{provides}->{http} = $self->{http_port} || 80;
	$self->{provides}->{https} = $self->{https_port} || 443;
	bless $self, $class;

	return $self;
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
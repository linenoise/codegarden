package Net::Automation;

=head1 NAME

Net::Automation - Simple automation of otherwise tedious network operations

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

=cut


use strict;
use version;
our $VERSION = qv(0.0.1);

use Net::Automation::Configuration;
use Net::Automation::Processor;


=head2 new

C<new> takes this class followed by optional named arguments:

=cut

sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;

	return $self;
}


=head2 run

c<run> parses command line arguments and launches automated process

Takes $self, returns exit status of that process.

=back

=cut

sub run {
	my ($self) = @_;
	
	if (my $configuration = Net::Automation::Configuration->new()->load()) {
		if (my $processor = Net::Automation::Processor->new()->load($configuration)) {
			return 1;
		}
	}
	
	return undef();
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
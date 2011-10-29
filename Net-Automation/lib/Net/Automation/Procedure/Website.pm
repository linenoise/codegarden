package Net::Automation::Procedure::Website;

use strict;
use version;
our $VERSION = qv(0.01);
use base qw(Net::Automation::Procedure);

=head1 NAME

Net::Automation::Procedure::Website - Automation procedure for managing a website on a remote server

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 PUBLIC METHODS

=cut 

use Quantum::Superpositions;

=head2 meta

C<meta> takes $self and returns metadata associated with this class

=back

=cut

sub meta{
	return {
		requires => {
			deploy => {
				source => [ 'at' ],  ### If no "on" is given, assume localhost
				destination => [ 'on', 'at' ],
			},
		},
		methods => {
			test => {'mockup' => {}},
			deploy => {
				### Using version control with remote encrypted shell access
				'SSH there and SCM down' => {
					source => [ 'scm' ],
					destination => [ 'ssh' ],
				},
				### Using version control with remote encrypted file acccess
				'SCM here and SCP up' => {
					source => [ 'scm' ],
					destination => [ 'scp' ],
				},
				### Using local file system with remote encrypted file access
				'SCP up from local filesystem' => {
					destination => [ 'scp' ],
				},
			},
		},		
	};
}


=head2 new

C<new> takes this class followed by optional named arguments:

=over

=item with

Contains the hash reference of configuration elements defined in the procedure: section of the relevant configuration file

=item on

Contains the array reference of active host objects for this process

=item options

Contains the hash reference of all command line options (such as -v and --ignore-security-warnings)

=back

=cut

sub new {
	my ($class, $args) = @_;
	
	my $self = $class->SUPER::new( $args );
	bless $self, $class;

	return $self;
}


=head2 signal

C<signal> receives a processing signal from the central Net::Automation::Processor.  Supported signals are:

=over

=item test

Tests the current configuration to make sure all requested automated actions can be performed

=item deploy

Deploys the website to the remote host

=item rollback

Rolls the currently deployed website back to the previous revision

=back

Takes $self and a scalar containing the signal to be processed

Return 1 on success, undef() on failure

=cut

sub signal {
	my ($self, $action) = @_;
	
	my $signals = {
		'test' => sub { return 1; },
		'deploy' => sub {
			my ($self) = @_;
			return $self->_signal_deploy();
		},
	};
	
	### Make sure we know what they're asking us to do
	unless (defined $signals->{$action}) {
		print __PACKAGE__ . " encountered an unprocessable action: $action\nExiting.\n";
		return undef();
	}
	
	### Do what they're asking us to do
	if ($self->_knows_how_this_can_possibly_work($action)) {
		print "\nProceeding with method '$self->{annointed_method}'\n\n" if $self->{options}->{verbose};
		if ($signals->{$action}->($self)) {
			return 1;
		} else {
			return undef();
		}
	}

}


=head1 PRIVATE METHODS

=head2 _signal_deploy

C<_signal_deploy> processes deployment action based on receipt of deploy signal from processor

Takes $self.  Return 1 on success, undef() on failure

=cut

sub _signal_deploy {
	my ($self) = @_;
	
	###
	#'SSH there and SCM down' => {
	#	source => [ 'scm' ],
	#	destination => [ 'ssh' ],
	#},
	### Using version control with remote encrypted file acccess
	#'SCM here and SCP up' => {
	#	source => [ 'scm' ],
	#	destination => [ 'scp' ],
	#},
	### Using local file system with remote encrypted file access
	#'SCP up from local filesystem' => {
	#	destination => ['scp']
	###	

	# print "Eigenstates: :".join(', ', eigenstates(any('abc','def','geh').any(1,2,3)))."\n\n\n";
	
	if ($self->{annointed_method} eq 'SCP up from local filesystem') {
		
		$self->{with}->{source}->{on} ||= 'localhost';
		
		if ($self->{on}->{ $self->{with}->{source}->{on} }) {
			if ($self->{on}->{ $self->{with}->{destination}->{on} }) {
				print "Uploading from $self->{with}->{source}->{on} at $self->{with}->{source}->{at} " . 
					  "to $self->{with}->{destination}->{on} at $self->{with}->{destination}->{at}.\n" 
					if $self->{options}->{verbose};

				if( $self->{options}->{verbose} > 2) {
					use Data::Dumper;
					print "Target host reference: $self->{on}->{ $self->{with}->{source}->{on} } // " . 
						  Dumper($self->{on}->{ $self->{with}->{source}->{on} })."\n\n";
				}
				
				return $self->{on}->{ $self->{with}->{source}->{on} }->upload(
					$self->{with}->{source}->{at},
					$self->{on}->{ $self->{with}->{destination}->{on} },
					$self->{with}->{destination}->{at},
					{
						via => 'scp',
						'ssh_config' => '~/.ssh/config',
						'ssh_options' => {
							TCPKeepAlive => 'yes',
							ServerAliveInterval => 30, 
						},
#						'flags' => ['recurse'],
					}
				);
				
			} else {
				print "Destination host $self->{destination}->{on} not defined in configuraiton file." .
				      "  Exiting.\n";
			}
		} else {
			print "Source host $self->{source}->{on} not defined in configuraiton file.  Exiting.\n";
		}
	}
	
	return 1;
}


=head1 AUTHORS

This module written by Dann Stayskal <dann@stayskal.com>.

=head1 COPYRIGHT

This module is Copyright (c) 2009 by Dann Stayskal <dann@stayskal.com>.

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
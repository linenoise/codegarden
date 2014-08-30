package Net::Automation::Procedure;

use strict;
use version;
our $VERSION = qv(0.01);

=head1 NAME

Net::Automation::Procedure - Superclass for automation procedures

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 PUBLIC METHODS

=cut 

use Quantum::Superpositions;

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
	
	my $self = {};
	foreach my $key (qw/with on options/) {
		$self->{$key} = $args->{$key} if $args && $args->{$key};
	}
	bless $self, $class;

	return $self;
}


=head1 PRIVATE METHODS

=head2 _knows_how_this_can_possibly_work

Determines whether (and how) this procedure, knowing only what it now knows, can feasibly run.

Takes $self and $action.  Returns a workng method (on success) or undef() (on failure).

=cut

sub _knows_how_this_can_possibly_work {
	my ($self, $action) = @_;
	my $meta = $self->meta();

	print "Figuring out how this can possibly work:\n" if $self->{options}->{verbose};

	### First, make sure the procedure input is well-formed (i.e. required keys are present)
	foreach my $host_function (keys(%{$meta->{requires}->{$action}})) {
		if ($self->{with} && $self->{with}->{$host_function}) {
			foreach my $param (@{$meta->{requires}->{$action}->{$host_function}}) {
				unless ($self->{with}->{$host_function}->{$param}) {
					print "Parameter $param missing in $host_function stanza of procedure configuration for " . __PACKAGE__ . "\nExiting.\n";
					return undef();
				}
 			}
		} else {
			print "$host_function stanza missing from procedure configuration for " . __PACKAGE__ . "\nExiting.\n";
			return undef();
		}
	}
	
	### Next, let's make sure those hosts are defined
	foreach my $host_function (keys(%{$meta->{requires}->{$action}})) {
		unless ($self->{on}->{$self->{with}->{$host_function}->{on}}) {
			print "$action $host_function, set to '$self->{with}->{$host_function}->{on}', is not defined " .
				  "as a host in the configuration file.\nExiting.\n";
			return undef();
		}
 	}
	
	
	### Finally, find a method by which we can do this that the involved hosts actually support
	my @available_methods;
	foreach my $method (sort(keys(%{$meta->{methods}->{$action}}))) {
		
		print "   - Evaluating '$method'... " if $self->{options}->{verbose};
		my $this_could_still_possibly_work = 1;
		
		foreach my $host (keys(%{$meta->{methods}->{$action}->{$method}})) {
			if ($this_could_still_possibly_work) {
				foreach my $service (@{$meta->{methods}->{$action}->{$method}->{$host}}) {
					if ($this_could_still_possibly_work) {
						unless ($self->{with}->{$host}->{on} &&
							    $self->{on}->{ $self->{with}->{$host}->{on} }->{provides}->{$service}) {
							print "nope.  $host doesn't provide $service.\n" 
								if $self->{options}->{verbose};
							$this_could_still_possibly_work = 0;
						}
					}
	 			}
			}
		}

		### If we can find a working method, remember it.
		if ($this_could_still_possibly_work) {
			print "OK\n" if $self->{options}->{verbose};
			push @available_methods, $method;
		}
	}
	
	if (scalar(@available_methods) == 1) {
		return $self->{annointed_method} = $available_methods[0];
	} elsif (scalar(@available_methods) > 1) {
		return $self->{annointed_method} = $self->_decide_between(
			\@available_methods, 
			'There\'s more than one way to do this.  Which of these do you prefer?',
			'You can set this preference in your configuration file in the procedure stanza.'
		);
	} else {
		print "No working method could be found for this host configuration.\n";
		return undef();
	}
}


=head2 _decide_between

Presents the user with a set of choices, gathers input with a prompt, and prints a configuration reminder

Takes $self (a blessed hashref), $choices (an arrayref of scalars), $prompt (a scalar), and $note (another scalar).  Returns the scalar chosen.

=cut

sub _decide_between {
	my ($self, $choices, $prompt, $note) = @_;
	
	unless (ref ($choices) eq 'ARRAY' && scalar(@$choices)) {
		print "Choices handed to Net::Automation::Procedure::_decide_between must be an array reference.\n";
		exit 1;
	}
	my $answer = 0;
	until ($answer > 0 && $answer <= scalar(@$choices)) {
		print "\n$prompt\n\n";
		print "Note: $note\n\n" if $self->{options}->{verbose};
		for (my $i = 0; $i < scalar(@$choices); $i++) {
			print $i + 1 . ") $choices->[$i]\n";
		}
		print "\n> ";
		$answer = <STDIN>;
		chomp $answer;
		
		unless ($answer =~ /^\d*$/) {
			$answer = 0;
		}
		if ($answer <= 0 || $answer > scalar(@$choices)) {
			print "\nPlease enter the number next to your prefered option and press return.\n" .
			      "Otherwise, you can use ^C to exit.\n"
		}
	}
	return $choices->[$answer-1];
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
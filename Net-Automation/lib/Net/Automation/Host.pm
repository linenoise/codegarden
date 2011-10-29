package Net::Automation::Host;

use version;
our $VERSION = qv(0.01);

=head1 NAME

Net::Automation::Host - Models a host for binding to services

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
	
	my $self = {};
	$self->{hostname} = $args->{hostname};
	$self->{is_localhost} = $args->{is_localhost} if $args->{is_localhost};
	bless $self, $class;

	return $self;
}


=head2 introspect

C<introspect> causes this host object to generate its {provides} keys based upon its {services} objects

Takes $self, returns enlightenment.

=cut

sub introspect {
	my ($self) = @_;
	
	foreach my $service_key ( keys(%{$self->{service}})) {
		foreach my $provision ( keys(%{$self->{service}->{$service_key}->{provides}})) {
			$self->{provides}->{$provision} = $service_key;
		}
	}

	return 'Chop wood, carry water.';
}


=head2 upload

C<upload> uploads a file from this host to another using scp (by default), sftp, https, http, or ftp

Takes $self (a blessed Host ref), $here (the scalar containing the local path to the file), $target (a blessed Host ref), $there (a scalar containing the remote path of the file), and a hash reference of arguments, including:

	via => 'scp', ### (or 'sftp', 'ftp', 'https', or 'http')
	command_options => { your => 'command', options => 'here'},

=cut 

sub upload {
	my ($self, $here, $target, $there, $args) = @_;
	
	### If they didn't tell us how they want it uploaded, figure out a workable method
	my $method = $args->{via} || '';
	unless ($method) {
		foreach (qw/scp/) {					### Peer-driven protocols (provides-and-provides)
			$method = $_ if $self->{provides}->{$_} && $target->{provides}->{$_};
		}
		foreach (qw/sftp https http ftp/) { ### Client-server protocols (consumes-from-provides)
			$method = $_ if $target->{provides}->{$_};
		}
	}

	my $upload_command = '';
	if ($method eq 'scp') {
		my $upload_options = {
			'from' => {
				file => $here,
			},
			'to' => {
				host => $target->{hostname},
				file => $there,
			},
		};
		foreach my $key (keys(%$args)) {
			$upload_options->{$key} = $args->{$key} unless $key eq 'via';
		}
		$upload_command = $self->_scp_command($upload_options);
		if (scalar(keys(%$upload_options))) {
			print 'Warning: Possible configuration problem.  '.
				  'Unused configuration keys passed to _scp_command constructor: ' . 
				   join(', ', map({
				   		ref($upload_options->{$_}) eq 'HASH' ?
					   		 "$_ (" . join(', ', sort(keys(%{$upload_options->{$_}}))) . ')' : 
							 $_
				   } sort(keys(%$upload_options))))."\n\n";
		}
	}

	return $self->_run_command( $upload_command );

}


=head2 download

C<download> downloads a file from another host to this one using scp (by default), sftp, https, http, or ftp

Takes: 

=cut 

sub download {
	my ($self) = @_;
}


=head1 PRIVATE METHODS

=head2 _run_command

=cut

sub _run_command {
	my ($self, $command) = @_;
	
	### TODO if $ENV{ask_permission_to_run_commands} is set, ask permission to run commands
	### (This will be useful for interactive testing and debugging)
	if ($self->{is_localhost}) {
		print "Running local command: `$command`\n";
		system($command);
	} else {
		### TODO break this out into SSH, RSH, and Telnet
		print "Running remote command: `$command`\n";
		system("ssh $self->{hostname} \"$command\"");
	}

	if ($? == -1) {
		print "Child failed to execute: $!\n";
		return undef();
	} elsif ($? & 127) {
		printf "Child died with signal %d, %s coredump\n",
		($? & 127), ($? & 128) ? 'with' : 'without';
		return undef();
	} elsif ($? == 0) {
		print "Child exited with zero status (good).\n";
		return 1;
	} else {
		printf "Child exited with value %d\n", $? >> 8;
		return 1;
	}

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
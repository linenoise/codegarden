package Net::Automation::Service::OpenSSH;

use version;
our $VERSION = qv(0.01);

=head1 NAME

Net::Automation::Service::OpenSSH - Models the behavior of OpenSSH

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

=cut

use strict;

=head2 new

C<new> takes this class followed by optional named arguments:

=over

=item host_key

The SSH host key configured for this service on this host

=item ssh_port

The SSH port on which this service listens

=back

=cut

sub new {
	my ($class, $args) = @_;
	
	my $self = {};
	foreach my $key (qw/host_key ssh_port/) {
		$self->{$key} = $args->{$key} if $args && $args->{$key};
	}
	$self->{provides}->{ssh} = $self->{ssh_port} || 22;
	$self->{provides}->{scp} = $self->{ssh_port} || 22;
	bless $self, $class;

	return $self;
}


=head2 _scp_command_options

C<_scp_command_options> constructs the sequence of arguments that should be passed to the scp(1) command for OpenSSH running on any arbitrary host.

Takes $self and a hash reference of options, such as:

	$self->_scp_command_options({
		'from' => {
			file => '/home/your_username/Sites/website/',
		},
		'to' => {
			host => 'your.webserver.com',
			file => '/var/www/website/',
			username => 'your_username_on_that_server',
			password => 'your_password_on_that_server',
		},
		'ssh_config' => '~/.ssh/config',
		'ssh_options' => {
			TCPKeepAlive => 'yes',
			ServerAliveInterval => 30, 
		},
		'flags' => ['recurse', 'quiet', 'batch', 'compress'],
	})

	TODO write this out in POD

=cut

sub _scp_command_options {
	my ($self, $args) = @_;
	
	### Sanity check: They have (minimally) from, to, and their respective files specified, right?
	unless(defined $args && defined $args->{from} && ref $args->{from} eq 'HASH' && 
		   defined $args->{from}->{file} && defined $args->{to} && ref $args->{to} eq 'HASH' && 
		   defined $args->{to}->{file}) {
		print "Fewer than minimum arguments passed to construct an SCP command.\n".
			  "Needed arguments include at least a {from}->{file} and a {to}->{file}.";
		return undef();
	}

	my $options = '';
	
	### If they passed flags, process them first
	if (defined $args && ref $args eq 'HASH' && defined $args->{flags} && ref $args->{flags} eq 'ARRAY' ) {
		my $flags = {
			force_ssh_1 => '1',
			force_ssh_2 => '2',
			force_ipv4 => '4',
			force_ipv6 => '6',
			batch => 'B',
			compress => 'C',
			preserve_times => 'p',
			quiet => 'q',
			recurse => 'r',
			verbose => 'v',
		};
		my @positions_to_clear;
		foreach my $flag (sort(keys(%$flags))) {
			if (defined $flag && $flag && grep /$flag/, @{$args->{flags}}) {
				$options .= " -$flags->{$flag}";
				my ($position) = grep {$args->{flags}->[$_] eq $flag } 0 .. scalar(@{$args->{flags}})-1;
				push @positions_to_clear, $position;
			}
		}
		delete $args->{flags}->[$_] foreach @positions_to_clear;
		delete $args->{flags} unless scalar(@{$args->{flags}});
	}
	
	### If they passed scp-specific options, process them next
	my $scp_options = {
		cipher => 'c',
		ssh_config => 'F',
		identity_file => 'i',
		bandwidth_limit => 'l',
		port => 'P',
		encryption_program => 'S',
	};
	foreach my $scp_option (sort(keys(%$scp_options))) {
		### Not using 'defined $args...' here -- if it's empty but defined (e.g. $a = ''), we don't want
		### to produce syntactically invalid forms like 'ssh -F -o SomethingElse=this' --Dann
		if ($args->{$scp_option}) { 
			$options .= " -$scp_options->{$scp_option} $args->{$scp_option}";
			delete $args->{$scp_option};
		}
	}
	
	### Did they specify any other SSH Config options? [-o ssh_option]
	if ($args->{ssh_options} && ref $args->{ssh_options} eq 'HASH') {
		foreach my $ssh_option (sort(keys(%{$args->{ssh_options}}))) {
			$options .= " -o $ssh_option=$args->{ssh_options}->{$ssh_option}";
			delete $args->{ssh_options}->{$ssh_option};
		}
		delete $args->{ssh_options};
	}
	
	### Construct the 'from' clause [[user@]host1:]file1
	my $from_clause = $args->{from}->{file};
	$from_clause = $args->{from}->{host}.':'.$from_clause if $args->{from}->{host};
	$from_clause = $args->{from}->{user}.'@'.$from_clause if $args->{from}->{user};
	$options .= " \"$from_clause\"";
	delete $args->{from}->{$_} foreach qw/file host user/;
	delete $args->{from} unless scalar(keys(%{$args->{from}}));
	
	### Construct the 'to' clause [[user@]host2:]file2
	my $to_clause = $args->{to}->{file};
	$to_clause = $args->{to}->{host}.':'.$to_clause if $args->{to}->{host};
	$to_clause = $args->{to}->{user}.'@'.$to_clause if $args->{to}->{user};
	$options .= " \"$to_clause\"";
	delete $args->{to}->{$_} foreach qw/file host user/;
	delete $args->{to} unless scalar(keys(%{$args->{to}}));
	
	
	return $options;
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
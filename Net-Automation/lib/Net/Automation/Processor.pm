package Net::Automation::Processor;

use version;
use strict;
our $VERSION = qv(0.01);

=head1 NAME

Net::Automation::Processor - Loader for automated tasks in the Net::Automation suite

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 PUBLIC METHODS

=cut

use Config;
use Data::Dumper;
use File::Find qw/find/;
use File::Spec::Functions;

=head2 new

C<new> Creates a new Net::Automation::Procedure object

=cut

sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;
	
	$self->_find_available_modules();

	return $self;
}

=head2 load

Parses the given configuration file, creates object trees, and executes provided action on the configured procedure.

Takes $self and $config (a valid Net::Automation::Configuration object)

Returns 1 on success, undef() on failure

=cut
sub load {
	my ($self, $configuration) = @_;
	
	### Sanity check
	unless ($configuration && ref $configuration eq 'Net::Automation::Configuration') {
		print "Invalid configuration passed to &Net::Automation::Procedure::proceed()\n";
		return undef();
	}
	
	print "Ready to Net::Automation::Processor::load().  Proceeding.\n\n" 
		if $configuration->{options}->{verbose};
	
	if (my $hosts = $self->_prepare_hosts({with =>$configuration})) {
		if (my $procedure = $self->_prepare_procedure({on => $hosts, with => $configuration})) {
			if ($procedure->signal($configuration->{action})) {
				print "Done.\n\n" if $configuration->{options}->{verbose};
				return 1;
			}
		}
	}
	
}


=head1 PRIVATE METHODS

=head2 _prepare_procedure

Instantiates the relevant procedure object from the configuration file, configures for running

Takes a hash reference of the following option:

=over

=item with 

The current valid Net::Automation::Configuration object

=item on

The array reference of Net::Automation::Host objects (and their subclasses)

=back

Returns a hash reference of active procedure object on success, undef() on failure

=cut

sub _prepare_procedure {
	my ($self, $args) = @_;
	
	my $procedure = $args->{with}->{configuration}->{procedure}->{for};
	print "Looking for procedure called $procedure... " if $args->{with}->{options}->{verbose} > 1;

	my $prebuilt_procedure = grep (
		{/Net::Automation::Procedure::$procedure$/} 
		keys(%{$self->{available_modules}})
	);
	if ($prebuilt_procedure) {
		$procedure = "Net::Automation::Procedure::$procedure";
	}
	print "using $procedure\n" if $args->{with}->{options}->{verbose} > 1;

	if ($self->{available_modules}->{$procedure}) {
		require $self->{available_modules}->{$procedure};
		my $proc = $procedure->new({
			'with' => $args->{with}->{configuration}->{procedure},
			'on' => $args->{on},
			'options' => $args->{with}->{options},
		});
		
		if ($args->{with}->{options}->{verbose} > 2) {
			$Data::Dumper::Indent = 1;
			print "Final dump of $procedure object: \n".Dumper($proc)."\n";
		}
		
		return $proc;
	} else {
		print "No procedure definition module agailable for $procedure\n";
		return undef();
	}
}


=head2 _prepare_hosts

Searches through the configuration file for valid-looking hosts, and prepares them as host objects

Takes a hash reference of the following option:

=over

=item with 

The current valid Net::Automation::Configuration object

=back

Returns a hash reference of active host objects on success, undef() on failure

=cut

sub _prepare_hosts {
	my ($self, $args) = @_;
	
	### Sanity check
	unless ($args && ref($args) eq 'HASH' && ref ($args->{with}) eq 'Net::Automation::Configuration') {
		print "Invalid configuration passed to &Net::Automation::Procedure::_prepare_hosts()\n";
		return undef();
	}
	
	my $hosts = {};
	foreach my $alias (sort(keys(%{$args->{with}->{configuration}->{hosts}}))) {
		print "Preparing host $alias...\n" if $args->{with}->{options}->{verbose} > 1;
		
		### Express displeasure if they didn't give us a hostname
		unless ($args->{with}->{configuration}->{hosts}->{$alias}->{hostname}) {
			print "No hostname provided for $alias.\nExiting.\n";
			return undef(); ### This is how I express displeasure.
		}
		
		### Figure out what host type they're talking about and create the object
		my $host = $self->_bind_host($alias, $args) || return undef();

		### Load the services for that host
		if ($args->{with}->{configuration}->{hosts}->{$alias}->{services}) {
			if (ref $args->{with}->{configuration}->{hosts}->{$alias}->{services} eq 'ARRAY') {
				$host->{service} ||= {};
				foreach my $service (@{$args->{with}->{configuration}->{hosts}->{$alias}->{services}}) {
					if (ref $service eq 'HASH') {
						### If the service is a hashref, bind it and shake it like they told us
						my @service_name = keys(%$service);
						$self->_bind_service($service_name[0], $host, $args, $service->{$service_name[0]}) 
							|| return undef();
					} else {
						### If the service is a scalar, just bind with defaults (they didn't give params)
						$self->_bind_service($service, $host, $args) || return undef();
					}					
				}
			} else {
				print "Services definition for $alias not a list.\n";
				return undef();
			}
		}
		
		### Introspection here is the process through which hosts learn what they can provide 
		### based on knowledge of which services are installed
		unless ($host->introspect()) {
			print "Introspection failed for host $alias.\nExiting.\n";
			return undef();
		}
		
		if ($args->{with}->{options}->{verbose} > 2) {
			$Data::Dumper::Indent = 1;
			print "Final dump of $alias: \n".Dumper($host)."\n";
		}
		
		### Include host in return hash
		$hosts->{$alias} = $host;
	}
	return $hosts;
}

=head2 _bind_service

Finds the appropriate service module through which to load a given service, then loads and binds that service to the pregivensented host.

Takes $self, $host, $esrvice (that is, what the service is called in the config file and the $host->{service} hash), a hash reference of the following option (containing the configuration object), and a hash reference of anything needed to be passed to the constructor for that service object

=over

=item configuration 

The current valid Net::Automation::Configuration object

=back

Returns an active host object (of some subclass of Net::Automation::Host) on success, undef() on failure

=cut

sub _bind_service {
	my ($self, $service, $host, $args, $newness) = @_;
	
	my $prebuilt_type = grep (
		{/Net::Automation::Service::$service$/} 
		keys(%{$self->{available_modules}})
	);
	if ($prebuilt_type) {
		$service = "Net::Automation::Service::$service";
	}
	print "   - Service Type: $service\n" if $args->{with}->{options}->{verbose} > 1;
	if ($self->{available_modules}->{$service}) {
		require $self->{available_modules}->{$service};
		$host->{service}->{$service} = $service->new($newness);
	} else {
		print "No service definition module agailable for $service\n";
		return undef();
	}
	
	return $self;
}


=head2 _bind_host

Finds the appropriate host module through which to load a given host, then loads and binds that host to the live host list.

Takes $self, $alias (that is, what the host is called in the config file), and a hash reference of the following option:

=over

=item configuration 

The current valid Net::Automation::Configuration object

=back

Returns an active host object (of some subclass of Net::Automation::Host) on success, undef() on failure

=cut

sub _bind_host {
	my ($self, $alias, $args) = @_;
	my $host;
	my $host_spec = {
		hostname => $args->{with}->{configuration}->{hosts}->{$alias}->{hostname},
	};
	my $local_hostname = `hostname`;
	chomp($local_hostname);
	$host_spec->{is_localhost} = 1 
		if $args->{with}->{configuration}->{hosts}->{$alias}->{hostname} eq $local_hostname;
		
	if (my $host_type = $args->{with}->{configuration}->{hosts}->{$alias}->{type}) {
		my $prebuilt_type = grep (
			{/Net::Automation::Host::$host_type$/} 
			keys(%{$self->{available_modules}})
		);
		if ($prebuilt_type) {
			$host_type = "Net::Automation::Host::$host_type";
		}
		print "   - Host Type: $host_type\n" if $args->{with}->{options}->{verbose} > 1;
		if ($self->{available_modules}->{$host_type}) {
			require $self->{available_modules}->{$host_type};
			$host = $host_type->new($host_spec);
		} else {
			print "No host definition module available for $host_type\n";
			return undef();
		}
	} else {
		### They didn't specify a host type.  Give them a Net::Automation::Host.
		print "   - Host Type: Net::Automation::Host\n" if $args->{with}->{options}->{verbose} > 1;
		use Net::Automation::Host;
		$host = Net::Automation::Host->new($host_spec);
	}
	return $host;
}

=head2 _find_available_modules

c<_find_available_modules> builds a list of installed Net::Automation modules and stores them in $self.

=cut

sub _find_available_modules {
	my ($self) = @_;

	my $modules;
	foreach my $dir (map({File::Spec->rel2abs($_)} grep({-d $_} @INC))) {
		my @canonical = ();
		find ({ wanted => 
				sub { push @canonical, canonpath($_) if /.*?\.pm\z/ }, 
				no_chdir => 1 }, $dir);
		foreach my $canonical (@canonical) {
			my $module = $canonical;
			$module =~ s/.*?$dir//;	### Remove the absolute path we searched in
			$module =~ s/.*?lib//;  ### Remove anything else up to and including lib
			$module =~ s/.*?$Config{archname}//; ### Remove architecture-specific path
			$module =~ s/^[\/\\]//; ### Remove any remaining slashes at the beginning
			$module =~ s/\.pm$//; ### Remove the extension
			$module =~ s/[\/\\]/::/g; ### Convert slashes into colon pairs
			$modules->{$module} ||= $canonical;
		}
	}

	$self->{available_modules} = $modules;
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
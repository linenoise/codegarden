package Net::Automation::Configuration;

use version;
our $VERSION = qv(0.1);

=head1 NAME

Net::Automation::Configuration - Loads and verifies configuration files for Net::Automation suite

=head1 SYNOPSIS

To build a configuration based on options in C<@ARGV>:

	$self->{configuration} = new Net::Automation::Configuration();
	$self->{configuration}->load()

If C<@ARGV> is empty, this looks for (and, if possible, parses) configuration files in default locations:

	./automation.yml
	./etc/automation.yml
	./conf/automation.yml
	./config/automation.yml

=head1 DESCRIPTION

This module loads and verifies (syntactically, not semantically) configuration files for Net::Automation suite.  These files are all L<YAML>-serialized data such as the following example:

	include:
	    - ~/.automation/hosts.yml

	hosts:
	    starfish:
	        hostname: starfish.exegesis.com
	        type: Linux
	        services:
	            - OpenSSH:
	                host_key: bc:f9:b5:55:4b:2c:07:d7:42:8c:00:2a:8d:f0:2c:de
	            - Apache2
	    porcupine:
	        hostname: porcupine.my-repository.com
	        services:
	            - OpenSSH
	            - Subversion

	procedure:
	    for: Website
	    codebase: 
	        on: starfish
	        at: /var/www/spiffy
	        using: 
	            - passenger
	            - ssh
	    source:
	        on: porcupine
	        at: /repos/spiffy         
	        using: svn+ssh

Notice the configuration tells Net::Automation I<how something works> not I<what to do with that something>.  Actions come later - this file simply reflects the essence of the system.  

In this configuration file, there the three stanzas: hosts, include, and procedure -- and they are processed in that order.

=head2 Hosts

The hosts section of a configuration file contains keys that tell L<Net::Automation> how to deal with the hosts he needs to deal with.  Each host definition can contain up to three keys:

=over

=item B<hostname>

Required, this key defines how you will address the host throughout the procedure.  It can be a domain name or an IP address.

=item B<type>

Optional, this defines the module in the L<Net::Automation::Host> namespace that will govern the behavior of this host.  If left undefined, it will default to the POSIXy goodness contained in L<Net::Automation::Host> itself.  You can specify host types outside of this namespace, too, simply by declaring a type using a fully qualified namespace.  This means that if you have your own custom host type (that subclasses L<Net::Automation::Host>) at Galactic::DataSworm::CustomHost, you can simply list that at the host type and Net::Automation will use your subclass.  Details on how to write these subclasses are in L<Net::Automation::Host>.

In short, to declare a generic Linux host using L<Net::Automation::Host::Linux>, declare C<type: Linux> for this key.  To declare a host conforming to your custom subclass, declare C<type: Galactic::DataSworm::CustomHost>.

=item B<services>

Optional, this contains an array reference of the services offered by that host.  Each element of that array reference a service definition module in the same manner as host definition modules above.  Declaring C<service: OpenSSH> will load and bind C<Net::Automation::Service::OpenSSH> to that host whereas declaring C<service: Galactic::Information::Network> will load and bind that module to that host.

=back

=head2 Includes

TODO FINISH POD HERE

=head2 Procedures

=head1 PUBLIC METHODS

=cut

use strict;
use Getopt::Long;
use YAML;
use Data::Dumper;

=head2 new

C<new> Creates a new Net::Automation::Configuration object.

=cut

sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;

	return $self;
}


=head2 load

c<load> constructs configuration information based on command line arguments and control files.  This is the single entry point and single exit point for this module.  By the time this has run its course, the data structrure stored in $self should have a structure that looks something like this:

	bless( {
	  'options' => {
	    'verbose' => 3,
	    'wants_help' => undef,
	    'configuration_file' => './fixtures/configs/website.yml',
	    'wants_version' => undef
	  },
	  'action' => 'test',
	  'configuration' => {
	    'hosts' => {
	      'porcupine' => {
	        'services' => [
	          'OpenSSH',
	          'Subversion'
	        ],
	        'hostname' => 'porcupine.my-repository.us'
	      },
	      'starfish' => {
	        'services' => [
	          {
	            'OpenSSH' => {
	              'host_key' => 'bc:f9:b5:55:4b:2c:07:d7:42:8c:00:2a:8d:f0:2c:de'
	            }
	          },
	          'Apache2'
	        ],
	        'type' => 'Linux',
	        'hostname' => 'starfish.exegesis.com'
	      },
	      'gmail' => {
	        'services' => [
	          'GMail'
	        ],
	        'hostname' => 'gmail.google.com'
	      }
	    },
	    'procedure' => {
	      'source' => {
	        'on' => 'porcupine',
	        'at' => '/repos/spiffy',
	        'using' => 'svn+ssh'
	      },
	      'for' => 'Website',
	      'codebase' => {
	        'on' => 'starfish',
	        'at' => '/var/www/spiffy',
	        'using' => [
	          'passenger',
	          'ssh'
	        ]
	      }
	    }
	  }
	}, 'Net::Automation::Configuration' );

Takes $self, returns $self on success, undef() on failure

=cut

sub load {
	my ($self) = @_;
	
	if ($self->_parse_command_line()) {
		if ($self->_load_configuration_file($self->{options}->{configuration_file})) {
			$Data::Dumper::Indent = 1;
			print "Current Net::Automation::Configuration --\n" . Dumper($self) . "\n\n" 
				if $self->{options}->{verbose} > 2;
			return $self;
		}
	}
	
	return undef();
}


=head1 PRIVATE METHODS

=head2 _load_configuration_file

c<_load_configuration_files> Loads and syntactically checks configuration file

Takes $self and path to a configuration file, returns 1 on success, undef() on failure

=cut

sub _load_configuration_file {
	my ($self, $configuration_file) = @_;
	
	print "Loading configuration file: $configuration_file\n"
	 	if $self->{options}->{verbose};
	if(my $config_tree = YAML::LoadFile($configuration_file)) {
		foreach my $key (sort(keys( %$config_tree ))) {
			
			### If there's an include stanza, process those depth-first
			if ($key eq 'include') {
				if (ref($config_tree->{include}) eq 'ARRAY') {
					foreach my $included_file (@{$config_tree->{include}}) {
						unless ($self->_load_configuration_file($included_file)) {
							return undef;
						}
					}
				} else {
					unless ($self->_load_configuration_file($config_tree->{include})) {
						return undef;
					}
				}
			} else {
				
			### If we're not currently parsing an include stanza, merge this configuration into the active one
				if (ref($config_tree->{$key}) eq 'HASH') {
					
					### If we're merging in a branch that's a hashkey, merge by subkeys one layer deep
					foreach my $subkey (keys(%{$config_tree->{$key}})) {
						print "Merging configuration branch $key - $subkey\n" if $self->{options}->{verbose} > 2;
						if (defined $self->{configuration}->{$key}->{$subkey}) {
							print "Configuration file collision encountered in file $configuration_file:\n".
								  "   In section $key, subkey $subkey redefined.\nExiting.\n";
							return undef;
						} else {
							$self->{configuration}->{$key}->{$subkey} = $config_tree->{$key}->{$subkey};					
						}
					}
				} else {
					
					### Otherwise, just copy over the branch
					print "Copying configuration branch $key\n" if $self->{options}->{verbose} > 2;
					$self->{configuration}->{$key} = $config_tree->{$key};					
				}
			}
		}
		return 1;
	} else {
		print "YAML syntax error in $configuration_file.";
		return undef;
	}
}


=head2 _parse_command_line

c<_parse_command_line> parses command line arguments

Takes $self, parses configuration options and stores them in $self.  Returns exit status corresponding to whether all required options are present.

=cut

sub _parse_command_line {
	my ($self) = @_;
	
	### Before we get to the rest of the command line, look for verbosity arguments 
	$self->{options}->{verbose} = grep(/^-v$/, @ARGV);
	print "Net::Automation version $Net::Automation::VERSION\n\n" if $self->{options}->{verbose};
	
	### Get and parse command line options
	if ($ARGV[0] && $ARGV[0] !~ /^-.*/) {
		$self->{action} = shift(@ARGV);		
	}
	if ($ARGV[0] && $ARGV[0] !~ /^-.*/) {
		$self->{options}->{configuration_file} = $self->_find_configuration(shift(@ARGV));		
	}
	$self->{options}->{verbose} = 0;
	GetOptions (
		"help" 						=> \$self->{options}->{wants_help},
		'v|verbose+' 				=> \$self->{options}->{verbose},
		'version' 					=> \$self->{options}->{wants_version},
	);
	
	### If all they want is help, help them.
	if ($self->{options}->{wants_help}) {
		return $self->_help_them({with =>'instructions'});
		return 1;
	}
	
	### If all they want is version information, version them.
	if ($self->{options}->{wants_version}) {
		return $self->_help_them({with =>'version'});
		return 1;
	}
	
	### Otherwise, check whether we have what we need
	if ($self->{action} && $self->{options}->{configuration_file}) {
		
		print "Running with command line arguments: \n" .
			join( "\n",map("   - $_: ".(
				ref( $self->{options}->{$_}) eq 'ARRAY' ?
					join( ', ', @{$self->{options}->{$_}}) :
					$self->{options}->{$_}
				),
				sort( grep {defined($self->{options}->{$_})} keys( %{$self->{options}} ) )
			)) . "\n\n" if $self->{options}->{verbose} > 1;

		return 1;
		
	} else {
		print "Insufficient arguments\n";
		$self->_help_them({with => 'usage'});
		return undef();
	}
}


=head2 _find_configuration

c<_find_configuration> finds the given configuration (and looks for the default one if none was given)

Takes the optional configuration name, returns path to the configuration (on success) or undef (on failure)

For example, if the configuration name "website" is passed, it will look in these places:

	./website.yml
	./etc/website.yml
	./conf/website.yml
	./config/website.yml

Furthermore, it doesn't strip out slashes.  So, if you pass a configuration name "fixtures/configs/website", it will look in:

	./fixtures/configs/website.yml
	./etc/fixtures/configs/website.yml
	./conf/fixtures/configs/website.yml
	./config/fixtures/configs/website.yml

If no configuration name is given, it will look for one called "automation" in all the usual places.

=cut

sub _find_configuration {
	my ($self,$name) = @_;

	$name ||= 'automation';
	
	foreach my $path_prefix (qw( ./ ./conf/ ./config/ )) {
		my $looking_for = $path_prefix . $name . '.yml';
		print "Looking for a procedure called $looking_for... " if $self->{options}->{verbose};
		if ( -e $looking_for && -r _ ) {
			print "found!\n\n" if $self->{options}->{verbose};
			return $looking_for;
		} else {
			print "nope.\n" if $self->{options}->{verbose};
		}
	}

	print "Couldn't find a relevant configuration.\n\n" if $self->{options}->{verbose};
	return undef();
}


=head2 _help_them

c<_help_them> prints a help message.

Takes $self and  hash reference of arguments, containing minimally the "with" key that determines which help message to present.

=cut

sub _help_them {
	my ($self, $args) = @_;
	
	my $help_header = "Net::Automation version $Net::Automation::VERSION \n";
					
	my $usage = "Usage: nap <action> [<configuration>] [--version] [--help] [-v]\n\n";
					
	if ($args->{'with'} eq 'instructions') {
		print $help_header .
			"This command runs Network Automation Procedures.\n\n" .
			"Net::Automation is free software, and comes with ABSOLUTELY NO WARRANTY.\n" .
			"It may be used, redistributed and/or modified under the terms of the \n" .
			"GNU General Public Licence. See LICENSE.txt for more information.\n\n".
			$usage .
			"<action>\n   The action to be run through the process defined in the configuration file\n" .
			"<configuration>\n   The configuration to use.  If none is specified, 'automation' will be used.\n" .
			"--help\n   Prints out detailed help information\n" .
			"--version\n   Prints out version information\n" .
			"-v --verbose (may be repeated)\n   Prints out debug information.\n\n";
		
	} elsif ($args->{'with'} eq 'usage') {
		print $help_header .
			($args->{because}?"$args->{because}\n\n":'') .
			$usage . 
			"See `nap --help` for full instructions.\n";
			
	} elsif ($args->{'with'} eq 'version') {
		print $help_header;
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
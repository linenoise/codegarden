package Tinhorn;

use strict;

=head1 NAME

Tinhorn - a Neural Dynamic Finance Engine

=head1 SYNOPSIS

	use Tinhorn qw(
		verify_dependencies
		verify_configuration update_configuration
		start_console start_webserver start_quotebot
		all_tests_pass unit_tests_pass integration_tests_pass functional_tests_pass
	);
	
	verify_dependencies() || install_dependencies();
	verify_configuration() || update_configuration();
	
	if (all_tests_pass()) {
		my $server_pid = start_app_web();
		my $console_pid = start_console();
	}

=head1 DESCRIPTION

tin·horn: n. I<A petty braggart who pretends to be rich and important.>

Tinhorn is a project to determine effective algorithms through which to model the behavior of publicly traded financial instruments.

=cut

require Exporter;

use lib qw(../../externals/lib/perl5/ ../../externals/lib/perl5/auto);

our $VERSION = '0.01';

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
	verify_dependencies
	verify_configuration update_configuration
	start_console start_webserver start_quotebot start_forexbot
	all_tests_pass unit_tests_pass integration_tests_pass functional_tests_pass
);

use Tinhorn::App::Console;
use Tinhorn::App::ForexBot;
use Tinhorn::App::Webserver;
use Tinhorn::Controller::Dependencies;

print "Tinhorn v. $VERSION\n\n";



=head1 DEPENDENCIES

All dependencies will be built in build/ and installed in externals/ if you don't have a compatible version of each installed on your system.

To display a list of all needed dependencies, run `script/verify/dependencies`.

To automatically install all needed dependencies, run `script/install/dependencies` or simply `make dep`.

=over 4

=item L<TAP::Harness>

=back

=cut

our $dependencies = {
	perl_modules => {
	### 'Module::Name'			=> $minimum_version,
		'AI::NNFlex'			=> 0,
		'DBD::SQLite'			=> 0,
		'DBD::mysql'			=> 0,
		'DBI'					=> 0,
		'File::stat'			=> 0,
		'Getopt::Long'			=> 0,
		'HTTP::Server::Simple' 	=> 0,
		'HTTP::Status'			=> 0,
		'List::Util'			=> 0,
		'LWP'					=> 0,
		'Math::Matrix'			=> 0,
		'PerlConsole'			=> 0,
		'TAP::Harness'			=> 0,
		'Template'				=> 0,
	},
};



=head1 EXPORTED FUNCTIONS

=head2 DEPENDENCY MANAGEMENT

=over 4

=item c<verify_dependencies>

Determines whether all dependencies are installed in externals/

Takes: nothing

Returns: 1 if everything is installed, 0 otherwise

=cut
sub verify_dependencies {
	
	return new Tinhorn::Controller::Dependencies()->verify($dependencies);
	
}



=head2 CONFIGURATION MANAGEMENT

=over 4
 
=item c<verify_configuration>

Determines whether everything needed is configured in conf/

Takes: nothing

Returns: 1 if everything is configured, 0 otherwise

=cut
sub verify_configuration {
		
}

 
=item c<update_configuration>

Generates any needed configuration files in conf/

Takes: nothing

Returns: 1 if everything could be configured, 0 otherwise

=cut
sub update_configuration {
		
}

=back




=head2 APPLICATION MANAGEMENT

=over 4
 
=item c<start_console>

Starts the Tinhorn::App::Console service

Takes: nothing

Returns: $pid if service could be started, 0 otherwise

=cut
sub start_console {
	
	return Tinhorn::App::Console->new()->run();
}


=item c<start_webserver>

Starts the Tinhorn::App::Webserver service

Takes: nothing

Returns: $pid if service could be started, 0 otherwise

=cut
sub start_webserver {

	return Tinhorn::App::Webserver->new(8080)->run();

}


=item c<start_quotebot>

Starts the Tinhorn::App::Quotebot service

Takes: nothing

Returns: $pid if service could be started, 0 otherwise

=cut
sub start_quotebot {
	
}

=back

=item c<start_forexbot>

Starts the Tinhorn::App::ForexBot service

Takes: nothing

Returns: exit status of ForexBot

=cut
sub start_forexbot {
	
	return Tinhorn::App::ForexBot->start();
	
}





=head2 TEST MANAGEMENT

=over 4
 
=item c<all_tests_pass>

Returns whether all tests pass

Takes: nothing

Returns: 1 if all tests pass, 0 otherwise

=cut
sub all_tests_pass {
	
}


=item c<unit_tests_pass>

Returns whether all unit tests pass

Takes: nothing

Returns: 1 if all unit tests pass, 0 otherwise

=cut
sub unit_tests_pass {
	
}


=item c<integration_tests_pass>

Returns whether all integration tests pass

Takes: nothing

Returns: 1 if all integration tests pass, 0 otherwise

=cut
sub integration_tests_pass {
	
}


=item c<functional_tests_pass>

Returns whether all functional tests pass

Takes: nothing

Returns: 1 if all functional tests pass, 0 otherwise

=cut
sub functional_tests_pass {
	
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
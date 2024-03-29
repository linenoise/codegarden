package Tinhorn::App::Console;

use strict;

=head1 NAME

Tinhorn::App::Console - The Tinhorn Console application

=head1 SYNOPSIS

	my $app = new Tinhorn::App::Console;
	my $pid = $app->start();

=head1 DESCRIPTION

This is the Tinhorn Console application.  It provides Tinhorn's console interface.

=cut

use PerlConsole;
use PerlConsole::Console;

$SIG{INT} = sub {
	print "\nInterrupt caught.  Exiting gracefully.\n";
	exit 0;
};

sub new {
	my ($class, $args) = @_;
	
	my $self = {};
	bless $self, $class;
	
	return $self;
}

sub run {

	my $console = PerlConsole::Console->new($PerlConsole::VERSION);

	$console->interpret("use Tinhorn;");
	$console->interpret("use Data::Dumper;");
	$console->interpret(':set output = dumper');
	
	while (defined(my $code = $console->getInput())) {
	    $console->interpret($code);
	} 
	$console->clean_exit(0);
	
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
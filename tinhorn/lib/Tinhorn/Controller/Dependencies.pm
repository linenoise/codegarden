package Tinhorn::Controller::Dependencies;

use strict;

=head1 NAME

Tinhorn::Controller::Dependencies - The Tinhorn Controller for dependency management

=head1 SYNOPSIS

	my $dependencies = new Tinhorn::Controller::Dependencies;

	my $verification_status = $dependencies->verify();
	my $installation_status = $dependencies->install();

=head1 DESCRIPTION

This is the Tinhorn controller for dependency management.  It allows Tinhorn to automatically detect and build any dependencies it might have, be they libraries, clients, servers, or other miscellaneous pieces of software we might need.

=cut

use List::Util qw(max);

=head1 METHODS

=over 4

=item C<new>

The Dependencies Controller constructor

Takes: C<$class>

Returns: C<$self> -- a blessed L<Tinhorn::Controller::Dependencies> object

=cut
sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;
	
	return $self;
}


=item C<verify>

Verify a set of dependencies

Takes: $self, $dependencies -- a hash reference of dependency information such as:

	my $dependencies = {
		perl_modules => qw/Tap::Harness/,
		libraries => qw/zlib/,
	}

Returns: 1 on success, 0 on failure

=cut
sub verify {
	my ($self, $dependencies) = @_;
	
	print "Verifying perl modules: \n";
	my $missing = 0;

	my $padding = max(map({length($_)} keys %{$dependencies->{perl_modules}}));

	foreach my $perl_module (sort keys %{$dependencies->{perl_modules}}) {
		print "   - $perl_module   ".' 'x($padding - length($perl_module));
	
		if (my $installed_version = $self->check_perl_module($perl_module)) {
			my $needed_version = $dependencies->{perl_modules}->{$perl_module};
			if ($installed_version >= $needed_version) {
				print "OK. version $installed_version";
			} else {
				print "Please upgrade. version $needed_version needed, version $installed_version installed";
				$missing++;
			}
		} else {
			print "Not available";
			$missing++;
		}
		
		print "\n";
	}
	
	if ($missing) {
		print "\nThere " . ($missing==1?'is':'are') .
		      " $missing missing " . ($missing==1?'dependency':'dependencies').".\n" .
		      "Please correct these and re-run this script.\n";
		return 0;
	} else {
		print "\nThere are no missing dependencies.\n";		
		return 1;
	}
	
}


=item C<check_perl_module>

Checks whether a given perl module is installed in externals/

Takes: $self, $perl_module

Returns: $version on success, 0 on failure

=cut
sub check_perl_module {
	my ($self, $perl_module) = @_;
	
	if (eval("require $perl_module")) {
	
		return eval("use $perl_module qw//; return \$".$perl_module."::VERSION \n");
		
	} else {
		return 0;
	}
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
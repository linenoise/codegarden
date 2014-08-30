package Tinhorn::Controller::Harvester;

use strict;

=head1 NAME

Tinhorn::Controller::Harvester - The Tinhorn Controller for dependency management

=head1 SYNOPSIS


=head1 DESCRIPTION

This is the Tinhorn controller for dependency management.  It allows Tinhorn to automatically detect and build any dependencies it might have, be they libraries, clients, servers, or other miscellaneous pieces of software we might need.

=cut

use URI::Escape;
use Tinhorn::Controller::Harvester::Dukascopy;


=head1 METHODS

=over 4

=item C<new>

The Harvester Controller constructor

Takes: C<$class>, C<$args> (options to store in $self)

Returns: C<$self> -- a blessed L<Tinhorn::Controller::Harvester> object

=cut
sub new {
	my ($class, $args) = @_;
	
	my $self = {
		opts 	   => $args,
		harvesters => {
			dukascopy => new Tinhorn::Controller::Harvester::Dukascopy($args),
		}
	};
	bless $self, $class;
	
	### Load up $self->{dispatch}
	foreach my $harvester (sort keys %{$self->{harvesters}}) {
		my $actions = $self->{harvesters}->{$harvester}->get_actions();
		foreach my $action (keys %$actions) {
			$self->{dispatch}->{$action} = $actions->{$action};
		}
	}
	
	return $self;
}


=item C<process_request>

Takes: C<$self> and C<$harvest_request>

Returns 1 on success, 0 on failure.

Note: harvest_request state stored in $harvest_request->disposition.

Note: error messages are stored in the message table.

=cut
sub process_request {
	my ($self, $harvest_request) = @_;
	
	if ($harvest_request->action) {
		if ($self->{dispatch}->{$harvest_request->action}) {
			
			my $vars = uri_unescape($harvest_request->vars);
			my %vars = ();
			
			foreach my $pair (split /&/, $vars) {
				my ($key, $value) = split /=/, $pair;
				$vars{$key} = $value;
			}
			
			my $success = $self->{dispatch}->{$harvest_request->action}->(
				$self->{harvesters}->{$harvest_request->harvester},
				$harvest_request->instrument_id, 
				\%vars
			);
			
			if ($success) {
				$harvest_request->delete();
				return 1;
			} else {
				$harvest_request->set(disposition => '1');
				$harvest_request->update();
				return 0;
			}
			
		} else {
			Tinhorn::Model::Message->insert({ 
				contents => 'Tinhorn::Controller::Harvester::process_request handed action it cannot process: '.
					        $harvest_request->action.' on harvest_request id '.$harvest_request->id
			});			
		}
	} else {
		Tinhorn::Model::Message->insert({ 
			contents => 'Tinhorn::Controller::Harvester::process_request handed malformed request (no action provided) '.
				        ' on harvest_request id '.$harvest_request->id
		});			
	}
}

=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
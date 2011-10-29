package Tinhorn::App::Harvest;

use strict;

=head1 NAME

Tinhorn::App::Harvest - The Tinhorn Harvest application

=head1 SYNOPSIS

	my $app = new Tinhorn::App::Harvest;
	my $pid = $app->new()->run();

=head1 DESCRIPTION

This is the Tinhorn Harvest application.  It pulls in data from all of tinhorn's input vectors.

=head1 METHODS

=over 4

=cut

use Tinhorn::Controller::Harvester;
use Getopt::Long;


=item C<new>

Class constructor

Takes $class

Returns $self.

=cut
sub new {
	my ($class, $args) = @_;
	
	my $self = {};
	bless $self, $class;
	
	return $self;
}


=item C<run>

Runs the harvester

Takes $self

Returns $runtime_status

=cut
sub run {
	my ($self) = @_;
	
	$SIG{INT} = sub {
		print "\nInterrupt caught.  Harvester exiting gracefully.\n";
		`rm tmp/harvester.pid`;
		exit 0;
	};

 	$self->{opts} = _get_options();
	$self->{harvester} = new Tinhorn::Controller::Harvester($self->{opts});
	print "Tinhorn v. $Tinhorn::VERSION\n\nHarvester starting.\n" unless $self->{opts}->{quiet};

	### Check to see if another harvester is already running
	if (-f 'tmp/harvester.pid') {
		if(my $pid = `cat tmp/harvester.pid`) {
			### There's already a PID file.  Is that process still running?
			my @proc_table = `ps -p $pid`;
			if (scalar(@proc_table) > 1) {
				print "Harvester already running on PID $pid. Exiting.\n";
				return;
			}
		}
	}

	### Tag us as running harvester on this PID
	`echo $$ > tmp/harvester.pid`;

	while (1) {
		if (my $harvest_request = $self->_get_next_harvest_request()) {
			$self->process_request($harvest_request);
		}
		
		### Sleep randomly so we don't beat the s*&% out of our various servers
		sleep(10 + int(rand(20)) + int(rand(15))**2);
	}
}


=item C<process_instrument>

Processes a given HarvestRequest object

Takes $self and $harvest_request

Returns nothing of value (stateful stuff is in MySQL)

=cut
sub process_request {
	my ($self, $harvest_request) = @_;
	
	if (ref($harvest_request) eq 'Tinhorn::Model::HarvestRequest') {

		$self->{harvester}->process_request($harvest_request);
		
	} else {
		Tinhorn::Model::Message->insert({ 
			contents => 'Tinhorn::App::Harvest::_get_next_harvest_request broke referential integrity. '.
						'Wanted Tinhorn::Model::HarvestRequest, got '.ref($harvest_request) 
		});
	}
}


sub _get_next_harvest_request{
	my ($self) = @_;
	
	return Tinhorn::Model::HarvestRequest->retrieve_from_sql(qq{
		disposition = 0
	    ORDER BY id asc
	    LIMIT 1
	 })->first();
}


sub _get_options {
	my $quiet  = 0;
	GetOptions(
		'q' => \$quiet,
	);
	return {
		quiet => $quiet,
	};
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
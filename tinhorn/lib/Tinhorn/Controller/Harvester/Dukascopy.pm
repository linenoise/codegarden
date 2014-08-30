package Tinhorn::Controller::Harvester::Dukascopy;

use strict;

=head1 NAME

Tinhorn::Controller::Harvester::Dukascopy - The Tinhorn Controller for dependency management

=head1 SYNOPSIS

	my $harvest_request = Tinhorn::Model::HarvestRequest->insert({
		instrument_id => $instrument_id,
		vars 		  => 'dukascopy_code=31&end_date=04.28.2010&interval=1D&num_points=2000'
		harvester     => 'dukascopy',
		action        => 'get_historical_data',
	});
	
	### Then make sure script/harvester is running.

=head1 DESCRIPTION

This is the Tinhorn controller for Dukascopy data harvesting.  It runs when a harvest request for this harvester is received by script/harvest and makes it through the poll queue.  It pulls data over the Dukascopy bridge (L<Tinhorn::Bridge::Dukascopy>) and populates market rate objects (L<Tinhorn::Model::MarketRate>) with the appropriate figures for the given intervals.

=cut

use Tinhorn::Bridge::Dukascopy;

our %intervals = (
	'60'   => 'm',
	'3600' => 'h',
	'1D'   => 'D',
	'7D'   => 'W',
	'1MO'  => 'M',
);

=head1 METHODS

=over 4

=item C<new>

The Harvester::Dukascopy Controller constructor

Takes: C<$class>, C<$args> (options to be stored in $self)

Returns: C<$self> -- a blessed L<Tinhorn::Controller::Harvester::Dukascopy> object

=cut
sub new {
	my ($class, $args) = @_;
	
	my $self = {
		opts   => $args,
		bridge => new Tinhorn::Bridge::Dukascopy,
	};
	bless $self, $class;
	
	return $self;
}


=item C<get_actions>

Returns the hash ref of valid dispatch actions to the Harvester controller

Takes: nothing

Returns: C<$actions> -- the hash ref of dispatch actions

=cut
sub get_actions {
	return {
		get_historical_data => sub {
			my ($self, $instrument, $vars) = @_;
			return $self->get_historical_data($instrument, $vars);
		},
	};
}


=item C<get_historical_data>

Takes: C<$self>, C<$instrument>, and C<$vars> (the hash ref of variables stored in the harvest_request)

Returns: 1 on success, 0 on failure

=cut
sub get_historical_data {
	my ($self, $instrument, $vars) = @_;

	my $success = 1;
	my $points = $self->{bridge}->get_historical_data(
		$vars->{dukascopy_code},
		$vars->{end_date},
		$vars->{interval},
		$vars->{num_points}
	);

	foreach my $point (@$points) {

		my ($month, $day, $year) = split /\//, $point->{date}; ### '05/13/2009', converting to ISO
		
		my $row = { 
			instrument_id 	=> $instrument->id,
			open 			=> $point->{open},
			high 			=> $point->{max},
			low 			=> $point->{min},
			close 			=> $point->{close},
			volume 			=> $point->{volume},
			quoted_at 		=> $point->{time},
			quoted_on 		=> "$year-$month-$day",
			interval_code	=> $intervals{$vars->{interval}}
		};
		my $market_rate = Tinhorn::Model::MarketRate->insert($row);
		
		unless (ref $market_rate eq 'Tinhorn::Model::MarketRate') {
			Tinhorn::Model::Message->insert({ 
				contents => 'Tinhorn::Controller::Harvester::Ducascopy broke referential integrity on insert. '.
							'Wanted Tinhorn::Model::MarketRate, got '.ref($market_rate)."\n Was trying to insert ".
							Dumper($row),
			});
			$success = 0;
		}
	}

	return $success;
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
package Tinhorn::Bridge::Dukascopy;

use strict;

=head1 NAME

Tinhorn::Bridge::Dukascopy - The Tinhorn bridge to the Dukascopy Swiss FOREX Marketplace

=head1 SYNOPSIS

	use Tinhorn::Bridge::Dukascopy;
	my $dukascopy = new Tinhorn::Bridge::Dukascopy;
	
	my @eur_usd = $dukascopy->(
		'31',          ### Financial instrument number
		'04.24.2010',  ### Start date
		'1D',          ### Interval (1D = 1 day)
	);

=head1 DESCRIPTION

This is the Tinhorn-Dukascopy bridge.  It lets us query financial instruments for historical data.

This is a bit of a hack around their public interface: http://www.dukascopy.com/freeApplets/exp/

=back

=head1 METHODS

=over 4

=cut

use base qw/Tinhorn::Bridge::_HTTP/;


=item C<get_historical_data>

Retrieves quote information for a financial instrument from Dukascopy

Takes: 

=over 4

=item C<$self>

=item C<$dukascopy_code> -- e.g. '31' ### Dukascopy code for this financial instrument

=item C<$end_date> (optional) -- e.g. '04.24.2010' (defaults to today's date)

=item C<$interval> (optional) -- e.g. '1D' (which is the default) Value options:

	60:		1 min
	3600:	1 hour
	1D:		1 day
	7D:		1 week
	1MO:	1 month

=item C<$num_points> (optional) -- the number of data points to get (2000 default) -- valid options 250, 500, 1000, 1500, and 2000
	
=back

Returns: @points on success, undef on failure.  On success, @points is just an array ref of hashrefs containing date, time, volume, open, close, min, and max prices:

	$VAR1 = [
          {
            'open' => '9.6',
            'close' => '9.47',
            'volume' => '91151',
            'min' => '9.2',
            'time' => '00:00:01',
            'date' => '05/12/2009',
            'max' => '9.89'
          },
          {
            'open' => '9.47',
            'close' => '8.64',
            'volume' => '96692',
            'min' => '8.57',
            'time' => '00:00:01',
            'date' => '05/13/2009',
            'max' => '9.47'
          },
		...
	];

=cut
sub get_historical_data {
	my ($self, $dukascopy_code, $end_date, $interval, $num_points) = @_;
	
	$end_date ||= $self->_get_dukascopy_date_stamp();
	
	unless ($end_date =~ /\d\d\.\d\d\.\d\d\d\d/) {
		print "Malformed date input on get_historical_data\n";
		return undef;
	}
	
	$interval ||= '1D';
	
	unless ($interval eq '60' || $interval eq '600' || $interval eq '3600' || $interval eq '1D' || $interval eq '7D' || $interval eq '1MO') {
		print "Malformed interval input on get_historical_data\n";
		return undef;
	}
	
	$num_points ||= 2000;

	unless ($num_points == 250 || $num_points == 500 || $num_points == 1000 || $num_points == 1500 || $num_points == 2000) {
		print "Invalid num_points input to get_historical_data\n";
		return undef;
	}
	
	my $uri = "http://www.dukascopy.com/freeApplets/exp/exp.php?".
			  "fromD=$end_date&np=$num_points&interval=$interval&".
			  "DF=m%2Fd%2FY&Stock=$dukascopy_code".
			  "&endSym=unix&split=tz";
	
	my $response = $self->http_get($uri, {
		no_mockup => 1,
		headers => {
			'Host' => 'www.dukascopy.com',
			'User-Agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3',
			'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
			'Accept-Language' => 'en-us,en;q=0.5',
			'Accept-Encoding' => 'gzip,deflate',
			'Accept-Charset' =>' ISO-8859-1,utf-8;q=0.7,*;q=0.7',
			'Keep-Alive' => '115',
			'Connection' => 'keep-alive',
			'Referer' => 'http://www.dukascopy.com/freeApplets/exp/',
		}
	});
	unless($response->is_success()) {
		print "Dukascopy HTTP request was unsuccessful\n";
		return;
	}

	my $data = $response->content();
	unless(scalar($data)) {
		print "No data returned by Dukascopy API\n";
		return;
	}
	
	my @data = split /\n/, $data;
	shift @data;  ### Get the headers off of there
	my @headers = ('date', 'time', 'volume', 'open', 'close', 'min', 'max');
	my @points = ();

	foreach my $row (@data) {
		$row =~ s/\n$//g;
		my $point = {};
		my @values = split /;/, $row;
		foreach my $index (0..scalar(@headers)-1) {
			$point->{lc($headers[$index])} = $values[$index];
		}
		push @points, $point;
	}
	
	return \@points;
}


sub _get_dukascopy_date_stamp {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	return sprintf('%02d.%02d.%4d', $mon+1,$mday,$year+1900);
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut
1;
__END__
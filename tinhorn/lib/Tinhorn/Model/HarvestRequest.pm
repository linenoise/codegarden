package Tinhorn::Model::HarvestRequest;

use strict;

=head1 NAME

Tinhorn::Model::HarvestRequest - The Tinhorn Model for Harvest Requests

=head1 SYNOPSIS

See L<Class::DBI>.

=head1 DESCRIPTION

See L<Class::DBI>.

=cut

use base 'Tinhorn::Model';

Tinhorn::Model::HarvestRequest->table('harvest_request');
Tinhorn::Model::HarvestRequest->columns(All => qw/id instrument_id harvester action vars disposition/);
Tinhorn::Model::HarvestRequest->has_a(instrument_id => 'Tinhorn::Model::Instrument');

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
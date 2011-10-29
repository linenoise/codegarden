package Net::Automation::Service::Subversion;

use version;
our $VERSION = qv(0.01);

=head1 NAME

Net::Automation::Service::Subversion - Models a subversion repository

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 METHODS

=cut

use strict;

=head2 new

C<new> takes this class followed by optional named arguments:

=over

=item named_argument

Description of that named argument

=back

For example:

	example_use_of_this_method()

=cut

sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;

	return $self;
}


#add
#blame (praise, annotate, ann)
#cat
#checkout (co)
#cleanup
#commit (ci)
#copy (cp)
#delete (del, remove, rm)
#diff (di)
#export
#help (?, h)
#import
#info
#list (ls)
#lock
#log
#merge
#mkdir
#move (mv, rename, ren)
#propdel (pdel, pd)
#propedit (pedit, pe)
#propget (pget, pg)
#proplist (plist, pl)
#propset (pset, ps)
#resolved
#revert
#status (stat, st)
#switch (sw)
#unlock
#update (up)



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

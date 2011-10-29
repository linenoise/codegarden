package Tinhorn::App;

use strict;

=head1 NAME

Tinhorn::View - The Tinhorn App superclass

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 TODO

=over 4

=back

=head1 METHODS

=over 4

=cut


=item C<daemonise>

Forks this shit into a daemon

Takes: C<$logfile>

Returns: death

=cut
sub daemonize {
        my ($logfile) = @_;
        ### Background this process
    chdir '/'               or die "Can't chdir to /: $!";
    open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
    open STDOUT, '>/dev/null'
                            or die "Can't write to /dev/null: $!";
    defined(my $pid = fork) or die "Can't fork: $!";
    exit if $pid;
    die "Can't start a new thread: $!" if setsid == -1;
    open STDERR, '>&STDOUT' or die "Can't dup stdout: $!";
        print "Channr backgrounded to PID $$\n";
}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Dann Stayskal.  All rights reserved.

=cut

1;
__END__
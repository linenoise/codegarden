#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Tabular::Format' ) || print "Failed to load!\n";
}

diag( "Testing Tabular::Format $Tabular::Format::VERSION, Perl $], $^X" );

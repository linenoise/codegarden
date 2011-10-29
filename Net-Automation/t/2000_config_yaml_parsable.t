use Test::More;
use File::Find qw( find );


my @files;
my $yesIKnowIOnlyUseItOnceButIDontWantToTurnWarningsOff = $File::Find::name;
find(sub { /.*\.yml$/ && push @files, $File::Find::name }, ('fixtures'));
plan tests => scalar(@files) + 1;

use_ok( 'YAML' );
foreach my $file (@files) {
	ok(YAML::LoadFile($file));
}

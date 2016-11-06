# $id: handlesUncertainty.t $
require AI::Memory::Associative::Bidirectional;
use Test::Simple tests => 1;

ok( 1, 'foo is bar' );



my $runs = [
  [ 
    [
      [ [1,0,1,0,1,0], [1,1,0,0] ],
      [ [1,1,1,0,0,0], [1,0,1,0] ],
    ], [
      [ [1,0,1,0,0,0], [0,0,0,0] ],
      [ [1,0,1,0,1,0], [1,1,0,0] ],
    ]
#  ], [ 
#      [
#      [ [1,0,1,0,1,0], [1,1,0,0] ],
#      [ [1,1,1,0,0,0], [1,0,1,0] ],
#    ], [
#      [ [1,0,1,0,1,0], [0,0,0,0] ],
#    ]
#  ], [ ### The example from Chapter 3, Problem 6d
#    [
#      [ [1,0,1,0,1,0], [1,1,0,0] ],
#      [ [1,1,1,0,0,0], [1,0,1,0] ],
#      [ [0,1,0,1,0,1], [0,0,1,1] ],
#      [ [0,0,0,1,1,1], [0,1,0,1] ],
#      [ [0,1,1,1,1,1], [0,1,1,1] ],
#      [ [1,1,1,1,1,1], [0,0,0,1] ],
#      [ [1,1,1,0,0,1], [0,1,0,1] ],
#      [ [1,1,1,0,0,1], [0,0,1,1] ],
#      [ [1,1,1,0,0,1], [0,1,0,0] ],
#    ], [
#      [ [1,0,1,0,1,0], [0,0,0,0] ],
#      [ [1,0,1,0,0,0], [0,0,0,0] ],
#      [ [0,0,1,1,1,0], [1,0,0,0] ],
#      [ [1,1,1,1,0,0], [1,0,0,0] ],
#    ]
#  ], [ ### The example given in class
#    [
#      [ [1,0,1], [0,1] ],
#    ], [
#      [ [1,0,1], [0,0] ],
#    ]
  ]
];

my $memory = new AI::Memory::Associative::Bidirectional;

print "Output from $0 (pid $$, user $ENV{LOGNAME})\n";
foreach my $dataset (0..scalar(@$runs)-1){

  print ''.('*'x70)."\nLoading initial values for dataset $dataset... ";
  my $inputs = $$runs[$dataset][0];#$$dataset[0];
  my $tests = $$runs[$dataset][1];#$$dataset[1];
  print "done.\n";

  foreach my $input (@$inputs){
    print "Loading input set: ";
    print vector($$input[0]).', '.vector($$input[1]).".\n";
    $memory->learn($$input[0],$$input[1]);
  }

  ### Print the completed weight matrix;
  print "\nFinal weight matrix:\n".table($$memory{weights})."\n";


  ### Step 8: Loop for steps 6 and 7 until the values stabilize
  foreach my $test (@$tests){
    print "Testing network for ".vector($$test[0]).', '.
      vector($$test[1])."...\n";
    if(my $steps = $memory->converge($$test[0],$$test[1])){
      print "  Stabilized to ".vector($$memory{X}).', '.vector($$memory{Y}).
            " after ".($steps)." iteration".($steps==1?'':'s')."\n\n";
    }
  }
}


### ### Subroutines ### ###

### vector()
# takes a vector, formats it for printing
# returns vector in human-readable form
###
sub vector{
  my $vector = shift;
  return '['.join(',',map({sprintf('%2d',$_)}@{$vector})).']';
}

### table()
# takes an array of vectors, formats it for printing
# returns array of vectors in human-readable form
###
sub table{
  my $vectors = shift;
  my $str = '';
  $str .= '   '.vector($_)."\n" foreach @$vectors;
  $str;
}

# $Id: handlesSuccess.t,v 0.0.1.1 2004/10/25 08:45:15 danne Exp $

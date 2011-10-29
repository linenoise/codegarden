package AI::Memory::Associative::Bidirectional;
use strict;
use warnings;
require Exporter; 
our @ISA = qw( Exporter );
our $VERSION = (split(/ /,'$Id: Bidirectional.pm,v $'))[2];

###
#
#      Bidirectional Associative Memory Object
#
# Copyright (c) 2004 Dann Stayskal <dann@stayskal.net>.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# $Id: Bidirectional.pm,v $
#
###

### new()
#  constructor for the memory object.
#  Takes nothing
#  Returns an empty memory object
###
sub new{
  my $memory = {};
  ($$memory{weights}, $$memory{X}, $$memory{Y}, $$memory{error}) = 
    ([],[],[],'');
  # IN NOMINE PATRI ET FILI ET SPIRITI SANCTI
  bless $memory, "AI::Memory::Associative::Bidirectional";
  # AMEN
  return $memory;
}

### sub learn
#  Inputs a set of vecors into the matrix, learning their patterns
#  Takes the memory object, the input pattern, and the output pattern
#  Returns nothing of value
###
sub learn($$$){
  my ($memory,$a,$b) = @_;
  foreach my $i (0..scalar(int(@{$a}))-1){
    $$memory{X}[$i] = 2 * $$a[$i] - 1;
  }
  foreach my $j (0..scalar(int(@{$b}))-1){
    $$memory{Y}[$j] = 2 * $$b[$j] - 1;
  }
  foreach my $i (0..scalar(int(@{$a}))-1){
    foreach my $j (0..scalar(int(@{$b}))-1){
      $$memory{weights}[$i][$j] ||=0; # initialize when we need it
      $$memory{weights}[$i][$j] = $$memory{weights}[$i][$j]
        + $$memory{X}[$i] * $$memory{Y}[$j];
    }
  }
  return 1;
}

### converge()
# runs iterations on the network until it converges to a stable value
# takes:
#   $memory - the memory object
#   $a - the input pattern
#   $b - the output pattern
# returns:
#   1 or greater - steps required to converge 
#   0 - failure ( read $$memory{error} for details )
###
sub converge($$$){
  my ($memory, $a, $b) = @_;
  my $aPrev = [];
  my $bPrev = [];

  my $step;
  ### If either vector changed on the last iteration, keep calculating
  for($step = 0; _changed($a,$aPrev)||_changed($b,$bPrev); $step++){

#      print "  Step $step: "._vector($a).', '._vector($b)."\n";
    $$aPrev[$_] = $$a[$_] foreach (0..int(@{$a})-1);
    $$bPrev[$_] = $$b[$_] foreach (0..int(@{$b})-1);

    ### Step 6: Calculate new A->B iteration
    foreach my $j (0..scalar(int(@{$b}))-1){
      my $sum = 0;
      foreach my $i (0..scalar(int(@{$a}))-1){
        $sum += $$a[$i] * $$memory{weights}[$i][$j];
      }
      if($sum > 0){
        $$b[$j] = 1;
      }elsif($sum < 0){
        $$b[$j] = 0;
      }
    }

    ### Step 7: Calculate new B->A iteration
    foreach my $i (0..scalar(int(@{$a}))-1){
      my $sum = 0;
      foreach my $j (0..scalar(int(@{$b}))-1){
        $sum += $$a[$i] * $$memory{weights}[$i][$j];
      }
      if($sum > 0){
         $$a[$i] = 1;
      }elsif($sum < 0){
         $$a[$i] = 0;
      }
    }
  }
  $$memory{X} = $a;
  $$memory{Y} = $b;
  return $step;
}


### _changed()
# takes two vectors, returns 1 if they're different, 0 if identical
###
sub _changed{
  my @vectors = @_;
  return 1 if !exists($vectors[0][0]) || !exists($vectors[1][0]);
  foreach(0..int(@{$vectors[1]})-1){
    return 1 if $vectors[0][$_] != $vectors[1][$_];
  }
  return 0;
}

### _vector()
# takes a vector, formats it for printing
# returns vector in human-readable form
###
sub _vector{
  my $vector = shift;
  return '['.join(',',map({sprintf('%2d',$_)}@{$vector})).']';
}

1;

package Tinhorn::Controller::Neural;

use strict;

=head1 NAME

Tinhorn::Controller::Neural - The Tinhorn Controller for neural functions

=head1 SYNOPSIS

	my $network = new Tinhorn::Controller::Neural;

=head1 DESCRIPTION

This is the Tinhorn controller for neural networks.

=cut

use AI::NNFlex::Backprop;
use AI::NNFlex::Dataset;

our @ISA = qw/Tinhorn::Controller/;


=head1 METHODS

=over 4

=item C<new>

The Mockups Controller constructor

Takes: C<$class>

Returns: C<$self> -- a blessed L<Tinhorn::Controller::Mockups> object

=cut
sub new {
	my ($class) = @_;
	
	my $self = {};
	bless $self, $class;
	
	return $self;
}


=item C<converge>

Converges a neural network to an (ideally) minimal error state

Takes: $self

Returns: $self

=cut
sub converge {
	my ($self, $uri) = @_;

	my $network = AI::NNFlex::Backprop->new(
		learningrate=>.00001,
		fahlmanconstant=>0,
		fixedweights=>1,
		momentum=>0.3,
		bias=>0
	);

	$network->add_layer(
		nodes=>2,
		activationfunction=>"linear"
	);


	$network->add_layer(
		nodes=>2,
		activationfunction=>"linear"
	);

	$network->add_layer(
		nodes=>1,
		activationfunction=>"linear"
	);


	$network->init();

	# Taken from Mesh ex_add.pl
	my $dataset = AI::NNFlex::Dataset->new([
	[ 1,   1   ], [ 2    ],
	[ 1,   2   ], [ 3    ],
	[ 2,   2   ], [ 4    ],
	[ 20,  20  ], [ 40   ],
	[ 10,  10  ], [ 20   ],
	[ 15,  15  ], [ 30   ],
	[ 12,  8   ], [ 20   ],

	]);

	my $err = 10;
	# Stop after 4096 epochs -- don't want to wait more than that
	for ( my $i = 0; ($err > 0.0001) && ($i < 4096); $i++ ) {
		$err = $dataset->learn($network);
		print "Epoch = $i error = $err\n";
	}

	foreach (@{$dataset->run($network)}) {
		foreach (@$_){print $_}
		print "\n";    
	}

	print "this should be 4000 - ";
	$network->run([2000,2000]);
	foreach (@{$network->output}) {
		print $_."\n";
	}

	foreach my $a ( 1..10 ) {
		foreach my $b ( 1..10 ) {
			my($ans) = $a+$b;
			my($nnans) = @{$network->run([$a,$b])};
			print "[$a] [$b] ans=$ans but nnans=$nnans\n" unless $ans == $nnans;
		}
	}

}


=back

=head1 COPYRIGHT

Copyright 2007-2010 by Danne Stayskal.  All rights reserved.

=cut

1;
__END__
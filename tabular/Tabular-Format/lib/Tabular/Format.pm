package Tabular::Format;

use warnings;
use strict;
use Carp;
use Data::Dumper;

our $VERSION = '0.2';

### Tab stops: 4

=head1 NAME

Tabular::Format - Formats tabular data using ASCII, CSV, Fixed-width, HTML, JSON, LaTeX, TSV, Wiki, XML, and YAML layouts.

=head1 DESCRIPTION

This module provides formatting for tabular data using a variety of common formats, serializations, and markup languages.  It is designed to accommodate the most prevalent use cases of tabular formatting.

=head2 DESIGN CONSIDERATIONS

What Tabular::Format doesn't do is manipulate your data--all it does is formatting.  This assumes that you know how you want your data structured, and only need some formatting applied to fit into a target environment(s).  You can hand it data as a two-dimensional array or as an array reference of hash references, or both concurrently.

If you're looking for a tabular module to help you structure your data, there are plenty of modules on CPAN for that.  Check out L<Data::Table>, L<Data::CTable>, and L<Data::Tabular>.

=head1 SYNOPSIS

There are two equivalent interfaces for this module.  The imperative interface works most quickly and simply to output a single table whereas the object oriented interface is designed to easily output a series of similarly formatted tables.

=head2 IMPERATIVE INTERFACE

	use Tabular::Format;

	print Tabular::Format::build({
		format  => 'ascii',
		title => 'Sample Presentation Data',
		labels => ['one', 'two', 'three'],
		data    => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	});

=head2 OBJECT-ORIENTED INTERFACE

Through the OOP interface, you can pass your tabular data and preferences into the constructor:

	use Tabular::Format;

	my $formatter = new Tabular::Format({
		format  => 'ascii',
		title => 'Sample Presentation Data',
		labels => ['one', 'two', 'three'],
		data    => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	});
	
	print $formatter->render();

Alternatively, you can simply spin up the object and hand your data and preferences to the accessor methods:

	use Tabular::Format;

	my $formatter = new Tabular::Format();
	
	$formatter->format('ascii');
	$formatter->title('Sample Presentation Data');
	$formatter->labels(['one', 'two', 'three']);
	
	$formatter->data([
		{one => 'alpha', two => 'bravo', three => 'charlie'},
		{one => 'delta', two => 'echo',  three => 'foxtrot'},
		{one => 'golf',  two => 'hotel', three => 'india'},
	]);
	
	print $formatter->render();

Of course, you can also mix these two approaches to fit your problem set.  All data and preferences handed to the formatter are preserved between calls to render().

=head1 FORMATS

=head2 ASCII

The ASCII display modality constructs an ASCII art-style format:

	.--------------------------.
	| Sample Presentation Data |
	|--------------------------|
	| one   | two   | three    |
	|--------------------------|
	| alpha | bravo | charlie  |
	| delta | echo  | foxtrot  |
	| golf  | hotel | india    |
	'--------------------------'

=cut

our $formatters = {

	'ascii' => sub {
		my ($table) = @_;
		
		### Calculate the column widths
	    my %width;
	    foreach my $column (@{$table->{labels}}) {
		
			### Find the longest row in that column by:
			$width{$column} = $_                        ### taking the last entry (i.e. the largest) from
				foreach sort( {$a<=>$b}                 ### an ascending-sorted list
					map({length(scalar($$_{$column}))}  ### which maps the lengths of each element
						@{$table->{data}}               ### from each element of that column's data
					)
				);
			
			### If the column label is longer than any of the data, widen the column appropriately
			$width{$column} = length(scalar($column)) if $width{$column} < length(scalar($column));
	    }
		print "Calculated column widths: ".Dumper(\%width) if $table->{debug};

	    ### Calculate table width
	    my $total_width = 4 + 3 * (scalar(@{$table->{labels}}) - 1);
	    $total_width += $width{$_} foreach keys %width;
	    if ($table->{title} && length($table->{title}) + 4 > $total_width) {

			### If the title's wider than the table, widen the table and the last column appropriately
			my $difference = length($table->{title}) + 4 - $total_width;
			$total_width += $difference;
			$width{$table->{labels}->[-1]} += $difference;
	    } 
		print "Calculated table width: $total_width\n" if $table->{debug};
		
		### Generate the sprintf() format
	    my $format = '   | '.join(' | ',map({'%-'.$width{$_}.'s'} @{$table->{labels}}))." |\n";
		print "Calculated sprintf format: $format\n" if $table->{debug};

	    ### Piece it together.  Start with the first ruled line
	    my $str = '   .' . '-' x ($total_width - 2) . ".\n";

	    ### If they asked for a title, give them one.
	    if ($table->{title}) {
			$str .= sprintf('   | %-'.($total_width-4).'s |',$table->{title})."\n"
					.'   |'.'-'x($total_width-2)."|\n";
	    }

	    ### Unless they asked for no labels, give them some and another line
	    unless ($table->{labels} eq 'none') {
			$str .= sprintf( $format, @{$table->{labels}} ); 
			$str .= '   |' . '-'x($total_width-2) . "|\n";
	    }

	    ### Add the completed data table
	    foreach my $line (@{$table->{data}}) {
			$str .= sprintf($format, map({$line->{$_}? $line->{$_} : ' '} @{$table->{labels}}));
	    }
	    $str .= '   \''.'-'x($total_width-2)."'\n";

	    ### Return it.
	    return $str;
	},

};






=head1 OBJECT ORIENTED METHODS

=head2 C<new>

Constructor for Tabular::Format objects

Takes:

=over 4

=item * (optional) C<configuration> (hash reference), conaining:

=over 4

=item * C<format> (scalar) - an overall format for the table

=item * C<title> (scalar) - a title for the table

=item * C<labels> (array reference) - a set of labels for the data in the table 

=item * C<data> (array reference) - a data set for the table

=back

=back

All of these configuration elements can also be handed to parallel accessor methods before finally calling render() on the object to generate the table.

=cut

sub new {
	my ($class, $args) = @_;
	$| = 1 if $args->{debug};
	
	my $self = {};	
	$self->{$_} = $args->{$_} foreach keys %$args;

	bless $self, $class;
	return $self;
}


=head2 C<format>

Accessor for the table's general format.

Takes:

=over 4

=item * (optional) C<format> (scalar) - Ideally, you would set this to one of 'ascii', 'csv', 'fixed-width', 'html', 'json', 'latex', 'tsv', 'wiki', 'xml', or 'yaml'.  Otherwise, you'll get an error rather than a table.

=back

Returns:

=over 4

=item * C<format> (scalar) if you called this with no arguments (as a getter)

=item * C<$self> (Tabular::Format) if you called this with an argument (as a setter)

=item * C<undef()> - on any error.  Messages available through warn (for my problems) and carp (for yours).

=back

=cut

sub format {
	my ($self, $value) = @_;
	
	if ($value) {  ### SETTER
		### Make sure it's a scalar
		unless (ref(\$value) eq 'SCALAR') {
			carp "Format must be a scalar";
			return undef();
		}
		### Make sure we know how to format that way
		unless (grep /$value/, keys(%$formatters) ) {
			carp "$value is an unknown format";
			return undef();
		}
		### If all is well, set and return
		$self->{format} = $value;
		return $self;
		
	} else {  ### GETTER
		return $self->{format};
	}
	
}


=head2 C<title>

Accessor for the table's general title.

Takes:

=over 4

=item * (optional) C<title> (scalar) - The title you want to give your table.

=back

Returns:

=over 4

=item * C<title> (scalar) if you called this with no arguments (as a getter)

=item * C<$self> (Tabular::Format) if you called this with an argument (as a setter)

=item * C<undef()> - on any error.  Messages available through warn (for my problems) and carp (for yours).

=back

=cut

sub title {
	my ($self, $value) = @_;
	
	if ($value) {  ### SETTER
		### Make sure it's a scalar
		unless (ref(\$value) eq 'SCALAR') {
			carp "Format must be a scalar";
			return undef();
		}
		### If all is well, set and return
		$self->{title} = $value;
		return $self;
		
	} else {  ### GETTER
		return $self->{title};
	}
	
}


=head2 C<render>

Final method used to construct and returns the formatted table.

If you don't set the format before calling render(), it will assume you want 'ascii'.

=cut

sub render {
	my ($self) = @_;
	return build($self);
}



=head1 IMPERATIVE FUNCTIONS

=head2 C<build>

Procedural function to construct and return a formatted table

=cut

sub build {
	my ($table) = @_;
	$| = 1 if $table->{debug};
	print "Tabular::Format::Render() called with ".Dumper($table)."\n" if $table->{debug};

	### make sure we're dealing with well-formed input
	$table->{format} ||= 'ascii';
	foreach my $datum (@{$table->{data}}){
		foreach my $column (@{$table->{labels}}){
			$datum->{$column} ||='';
		}
	}
	
	### make sure we have the formatter they want
	unless ($formatters->{$table->{format}}) {
		carp "Tabular::Format can't serialize to $table->{format}";
		return '';
	}

	print "Dispatching to $table->{format} formatter.\n" if $table->{debug};
	return $formatters->{$table->{format}}->($table);	
}





=head1 AUTHOR

Danne Stayskal, C<< <danne at stayskal.com> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-tabular-format at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tabular-Format>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tabular::Format

Additionally, support and documentaiton is available on the Tabular::Format website:

	L<http://danne.stayskal.com/software/tabular-format>


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2004-2010 Danne Stayskal.  Very few rights reserved:

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Tabular::Format

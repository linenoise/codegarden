package Data::Table::Formatter;

use warnings;
use strict;
use Carp;
use Data::Dumper;

our $VERSION = '0.2';

### Tab stops: 4

=head1 NAME

Data::Table::Formatter - Formats tabular data using ASCII, CSV, Fixed-width, HTML, JSON, LaTeX, TSV, Wiki, XML, and YAML layouts.


=head1 DESCRIPTION

This module provides formatting for tabular data using a variety of common formats, serializations, and markup languages.  It is designed to easily accommodate the most prevalent use cases of tabular formatting.


=head2 DESIGN CONSIDERATIONS

Keeping with the UNIX philosophy of "do one thing and do it well," what Data::Table::Formatter I<doesn't> do is manipulate your data.  All it does is formatting.  It assumes that you know how you want your data structured, and only need some presentation sugar applied to fit into a target environment(s).  You can hand it data as a two-dimensional array or as an array reference of hash references, or both concurrently.

If you're looking for a tabular data module to help you I<structure> your data, there are plenty of other modules on CPAN for that.  Check out L<Data::Table>, L<Data::CTable>, and L<Data::Tabular>.


=head1 SYNOPSIS

There are two equivalent interfaces for this module.  The imperative interface works most quickly and simply to output a single table whereas the object oriented interface is designed to easily output a series of similarly formatted tables.


=head2 IMPERATIVE INTERFACE

	use Data::Table::Formatter;

	print Data::Table::Formatter::build({
		layout  => 'ascii',
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

	use Data::Table::Formatter;

	my $formatter = new Data::Table::Formatter({
		layout  => 'ascii',
		title => 'Sample Presentation Data',
		labels => ['one', 'two', 'three'],
		data    => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	});
	
	print $formatter->render();

Alternatively, you can spin up the object and hand your data and preferences to the accessor methods:

	use Data::Table::Formatter;

	my $formatter = new Data::Table::Formatter();
	
	$formatter->layout('ascii');
	$formatter->title('Sample Presentation Data');
	$formatter->labels(['one', 'two', 'three']);
	
	$formatter->data([
		{one => 'alpha', two => 'bravo', three => 'charlie'},
		{one => 'delta', two => 'echo',  three => 'foxtrot'},
		{one => 'golf',  two => 'hotel', three => 'india'},
	]);
	
	print $formatter->render();

Of course, you can also mix these two approaches to fit your problem set.  All data and preferences handed to the formatter are preserved between calls to render().


=head1 LAYOUTS

=head2 ASCII

The ASCII display modality constructs an ASCII art-style layout:

	.--------------------------.
	| Sample Presentation Data |
	|--------------------------|
	| one   | two   | three    |
	|--------------------------|
	| alpha | bravo | charlie  |
	| delta | echo  | foxtrot  |
	| golf  | hotel | india    |
	'--------------------------'

Note: the ASCII display modality takes one optional argument: no_labels.  If this is set to something that evaluates to true, the labels will be not be printed:

	Data::Table::Formatter::build({
		layout  => 'ascii',
		title => 'Sample Presentation Data',
		labels => ['one', 'two', 'three'],
		data    => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	});

=cut

our $layouts = {

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
	    unless ($table->{options} && $table->{options}->{no_labels}) {
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

=head2 CSV

Not yet implemented

=head2 Fixed

Not yet implemented

=head2 HTML

Not yet implemented

=head2 JSON

Not yet implemented

=head2 LaTeX

Not yet implemented

=head2 TSV

Not yet implemented

=head2 Wiki

Not yet implemented

=head2 XML

Not yet implemented

=head2 YAML

Not yet implemented



=head1 OBJECT ORIENTED METHODS

=head2 C<new>

Constructor for Data::Table::Formatter objects

Takes:

=over 4

=item * (optional) C<configuration> (hash reference), conaining:

=over 4

=item * C<layout> (scalar) - an overall layout for the table ('ascii', 'csv', etc)

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


=head2 C<layout>

Accessor for the table's general layout.

Takes:

=over 4

=item * (optional) C<layout> (scalar) - Ideally, you would set this to one of 'ascii', 'csv', 'fixed-width', 'html', 'json', 'latex', 'tsv', 'wiki', 'xml', or 'yaml'.

=back

Returns:

=over 4

=item * C<layout> (scalar) if you called this with no arguments (as a getter)

=item * C<$self> (Data::Table::Formatter) if you called this with an argument (as a setter)

=item * C<undef()> - on any error.  Messages available through warn (for my problems) and carp (for yours).

=back

=cut

sub layout {
	my ($self, $value) = @_;
	
	if ($value) {  ### SETTER
		### Make sure it's a scalar
		unless (ref(\$value) eq 'SCALAR') {
			carp "# Layout must be a scalar";
			return undef();
		}
		### Make sure we know how to format that way
		unless (grep /$value/, keys(%$layouts) ) {
			carp "# $value is an unknown layout";
			return undef();
		}
		### If all is well, set and return
		$self->{layout} = $value;
		return $self;
		
	} else {  ### GETTER
		return $self->{layout};
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

=item * C<$self> (Data::Table::Formatter) if you called this with an argument (as a setter)

=item * C<undef()> - on any error.  Messages available through warn (for my problems) and carp (for yours).

=back

=cut

sub title {
	my ($self, $value) = @_;
	
	if ($value) {  ### SETTER
		### Make sure it's a scalar
		unless (ref(\$value) eq 'SCALAR') {
			carp "# Title must be a scalar";
			return undef();
		}
		### If all is well, set and return
		$self->{title} = $value;
		return $self;
		
	} else {  ### GETTER
		return $self->{title};
	}
	
}


=head2 C<labels>

Accessor for the table's column labels.

Takes:

=over 4

=item * (optional) C<labels> (array reference) - The column labels you want to give your table.

=back

Returns:

=over 4

=item * C<labels> (array reference) if you called this with no arguments (as a getter)

=item * C<$self> (Data::Table::Formatter) if you called this with an argument (as a setter)

=item * C<undef()> - on any error.  Messages available through warn (for my problems) and carp (for yours).

=back

=cut

sub labels {
	my ($self, $value) = @_;
	
	if ($value) {  ### SETTER
		### Make sure it's a scalar
		unless (ref($value) eq 'ARRAY') {
			carp "# Labels must be an array reference";
			return undef();
		}
		### If all is well, set and return
		$self->{labels} = $value;
		return $self;
		
	} else {  ### GETTER
		return $self->{labels};
	}
	
}


=head2 C<data>

Accessor for the table's data.

Takes:

=over 4

=item * (optional) C<data> (array reference) - The column data you want to give your table.

=back

Returns:

=over 4

=item * C<data> (array reference) if you called this with no arguments (as a getter)

=item * C<$self> (Data::Table::Formatter) if you called this with an argument (as a setter)

=item * C<undef()> - on any error.  Messages available through warn (for my problems) and carp (for yours).

=back

=cut

sub data {
	my ($self, $value) = @_;
	
	if ($value) {  ### SETTER
		### Make sure it's an array reference
		unless (ref($value) eq 'ARRAY') {
			carp "# Data must be an array reference";
			return undef();
		}
		### If all is well, set and return
		$self->{data} = $value;
		return $self;
		
	} else {  ### GETTER
		return $self->{data};
	}
	
}


=head2 C<options>

Accessor for the table's formatter's options.

Takes:

=over 4

=item * (optional) C<options> (hash reference) - any formatter-specific options.

=back

Returns:

=over 4

=item * C<options> (hash reference) if you called this with no arguments (as a getter)

=item * C<$self> (Data::Table::Formatter) if you called this with an argument (as a setter)

=item * C<undef()> - on any error.  Messages available through warn (for my problems) and carp (for yours).

=back

=cut

sub options {
	my ($self, $value) = @_;
	
	if ($value) {  ### SETTER
		### Make sure it's a hash reference
		unless (ref($value) eq 'HASH') {
			carp "# Options must be a hash reference";
			return undef();
		}
		### If all is well, set and return
		$self->{options} = $value;
		return $self;
		
	} else {  ### GETTER
		return $self->{options};
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

Takes:

=over 4

=item * C<configuration> (hash reference), conaining:

=over 4

=item * C<labels> (array reference) - a set of labels for the data in the table 

=item * C<data> (array reference) - a data set for the table

=item * (optional) C<layout> (scalar) - an overall layout for the table ('ascii', 'csv', etc).  Will assume 'ascii' if not set.

=item * (optional) C<title> (scalar) - a title for the table

=item * (optional) C<options> (hash reference) - any optional formatter-specific parameters

=back

=back

All of these configuration elements can also be handed to parallel accessor methods before finally calling render() on the object to generate the table.

=cut

sub build {
	my ($table) = @_;
	$| = 1 if $table->{debug};
	print "Data::Table::Formatter::Render() called with ".Dumper($table)."\n" if $table->{debug};

	### Make sure data is well-formed
	unless (ref($table->{data}) eq 'ARRAY') {
		carp "# Data must be an array reference";
		return undef();
	}

	### Make sure labels are well-formed
	unless (ref($table->{labels}) eq 'ARRAY') {
		carp "# Labels must be an array reference";
		return undef();
	}
	
	### Make sure title, if provided, is well-formed
	if ($table->{title} && ref($table->{title})) {
		carp "# Title must be a scalar";
		return undef();
	}

	### Make sure layout, if provided, is well-formed
	if ($table->{layout} && ref($table->{layout})) {
		carp "# Layout must be a scalar";
		return undef();
	}

	### Make sure options, if provided, is well-formed
	if ($table->{options} && ref($table->{options}) ne 'HASH') {
		carp "# Options must be a hash reference";
		return undef();
	}

	### Make sure we have the layout they want
	unless ($layouts->{$table->{layout}}) {
		carp "# Data::Table::Formatter can't serialize to $table->{layout}";
		return '';
	}

	### Make sure all data cells are initialized
	$table->{layout} ||= 'ascii';
	foreach my $datum (@{$table->{data}}){
		foreach my $column (@{$table->{labels}}){
			$datum->{$column} ||='';
		}
	}
	
	### Dispatch to relevant formatter
	print "Dispatching to $table->{layout} layout.\n" if $table->{debug};
	return $layouts->{$table->{layout}}->($table);
}


=head1 AUTHOR

Dann Stayskal, C<< <dann at stayskal.com> >>


=head1 BUGS AND FEATURE REQUESTS

Before notifying me of any bugs or requesting any new features, please check the listing on RT, CPAN's request tracker:

    L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Table-Formatter>

Once you've verified that your bug has not yet been reported or your feature requested, please report it to C<bug-data-table-formatter at rt.cpan.org>, or through the web interface above.  It will notify me, and you'll automatically be notified of progress on your bug or feature as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::Table::Formatter

Additionally, support and documentation is available on the Data::Table::Formatter website:

	L<http://dann.stayskal.com/software/data-table-formatter>

To annotate the documentation for this module, visit AnnoCPAN, Annotated CPAN documentation:

    L<http://annocpan.org/dist/Data-Table-Formatter>

Finally, if you like or dislike this module, please rate it constructively at CPAN Ratings:

    L<http://cpanratings.perl.org/d/Data-Table-Formatter>


=head1 LICENSE AND COPYRIGHT

Copyright 2004-2010 Dann Stayskal.  Very few rights reserved:

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Data::Table::Formatter

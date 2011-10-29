#!perl -T

use strict;
use warnings;
use Test::More tests => 20;
use Test::Warn;

BEGIN {
    use_ok( 'Data::Table::Formatter' );
}

my $sample_table = {
	layout => 'ascii',
	title => 'Sample Presentation Data',
	labels => ['one', 'two', 'three'],
	data => [
		{one => 'alpha', two => 'bravo', three => 'charlie'},
		{one => 'delta', two => 'echo',  three => 'foxtrot'},
		{one => 'golf',  two => 'hotel', three => 'india'},
	],
	options => {},
};



### ### ### GESTALT ### ### ###

### Make sure we have all the methods we'll need
can_ok(
	'Data::Table::Formatter', 
	qw/new layout title labels data render/
);

### Make sure we can spin up the object
my $formatter = new_ok('Data::Table::Formatter');



### ### ### LAYOUTS ### ### ###

### Make sure we get a warning on malformed input
warning_is { 
	$formatter->layout(['malformed input']) 
} {
	carped => "# Layout must be a scalar"
};

### Make sure we get a warning on unkonwn layout input
warning_is { 
	$formatter->layout('unknown layout') 
} {
	carped => "# unknown layout is an unknown layout"
};

### Make sure we can set a layout and get the handler back
isa_ok(
	$formatter->layout($sample_table->{layout}),
	'Data::Table::Formatter'
);

### Make sure that what we gave them and what we get back are the same
is_deeply(
	$formatter->layout(),
	$sample_table->{layout},
	'layout method properly set well-formed input'
);



### ### ### TITLES ### ### ###

### Make sure we get a warning on malformed input
warning_is { 
	$formatter->title(['malformed input']) 
} {
	carped => "# Title must be a scalar"
};

### Make sure we can set a title and get the handler back
isa_ok(
	$formatter->title($sample_table->{title}),
	'Data::Table::Formatter'
);

### Make sure that what we gave them and what we get back are the same
is_deeply(
	$formatter->title(),
	$sample_table->{title},
	'layout method properly set well-formed input'
);



### ### ### DATA ### ### ###

### Make sure we get a warning on malformed input
warning_is { 
	$formatter->data('malformed input') 
} {
	carped => "# Data must be an array reference"
};

### Make sure we can set a data and get the handler back
isa_ok(
	$formatter->data($sample_table->{data}),
	'Data::Table::Formatter'
);

### Make sure that what we gave them and what we get back are the same
is_deeply(
	$formatter->data(),
	$sample_table->{data},
	'layout method properly set well-formed input'
);



### ### ### Labels ### ### ###

### Make sure we get a warning on malformed input
warning_is { 
	$formatter->labels('malformed input') 
} {
	carped => "# Labels must be an array reference"
};

### Make sure we can set labels and get the handler back
isa_ok(
	$formatter->labels($sample_table->{labels}),
	'Data::Table::Formatter'
);

### Make sure that what we gave them and what we get back are the same
is_deeply(
	$formatter->labels(),
	$sample_table->{labels},
	'layout method properly set well-formed input'
);



### ### ### Options ### ### ###

### Make sure we get a warning on malformed input
warning_is { 
	$formatter->options('malformed input') 
} {
	carped => "# Options must be a hash reference"
};

### Make sure we can set options and get the handler back
isa_ok(
	$formatter->options($sample_table->{options}),
	'Data::Table::Formatter'
);

### Make sure that what we gave them and what we get back are the same
is_deeply(
	$formatter->options(),
	$sample_table->{options},
	'options method properly set well-formed input'
);



### ### ### RENDERING ### ### ###

### make sure we can render the table
my $table = $formatter->render();
is(
	$table,
	<<__HERE__
   .--------------------------.
   | Sample Presentation Data |
   |--------------------------|
   | one   | two   | three    |
   |--------------------------|
   | alpha | bravo | charlie  |
   | delta | echo  | foxtrot  |
   | golf  | hotel | india    |
   '--------------------------'
__HERE__
,
   'Sample table rendered correctly'
);

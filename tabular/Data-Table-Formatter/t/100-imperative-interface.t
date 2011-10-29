#!perl -T

use strict;
use warnings;
use Test::More tests => 9;
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
	]
};

my $correct_ascii = <<__HERE__
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
;


### ### ### GESTALT ### ### ###

### Make sure we have all the methods we'll need
can_ok(
	'Data::Table::Formatter', 
	qw/build/
);



### ### ### UNSUPPORTED INPUTS ### ### ###

### Make sure we get a warning on unsupported layout
$sample_table->{layout} = 'unsupported layout';
warning_is { 
	Data::Table::Formatter::build($sample_table); 
} {
	carped => "# Data::Table::Formatter can't serialize to unsupported layout"
};



### ### ### MALFORMED INPUTS ### ### ###

### Make sure we get a warning on malformed layout
$sample_table->{layout} = ['ascii'];
warning_is { 
	Data::Table::Formatter::build($sample_table); 
} {
	carped => "# Layout must be a scalar"
};
$sample_table->{layout} = 'ascii';


### Make sure we get a warning on malformed data
$sample_table->{data} = 'some data';
warning_is { 
	Data::Table::Formatter::build($sample_table); 
} {
	carped => "# Data must be an array reference"
};
$sample_table->{data} = [
	{one => 'alpha', two => 'bravo', three => 'charlie'},
	{one => 'delta', two => 'echo',  three => 'foxtrot'},
	{one => 'golf',  two => 'hotel', three => 'india'},
];


### Make sure we get a warning on malformed title
$sample_table->{title} = ['Sample Presentation Data'];
warning_is { 
	Data::Table::Formatter::build($sample_table); 
} {
	carped => "# Title must be a scalar"
};
$sample_table->{title} = 'Sample Presentation Data';


### Make sure we get a warning on malformed labels
$sample_table->{labels} = 'one';
warning_is { 
	Data::Table::Formatter::build($sample_table); 
} {
	carped => "# Labels must be an array reference"
};
$sample_table->{labels} = ['one', 'two', 'three'];


### Make sure we get a warning on malformed options
$sample_table->{options} = 'one';
warning_is { 
	Data::Table::Formatter::build($sample_table); 
} {
	carped => "# Options must be a hash reference"
};
$sample_table->{options} = {};


### ### ### RENDERING ### ### ###

### Make sure we can render the table
my $table = Data::Table::Formatter::build($sample_table);
is(
	$table,
	$correct_ascii,
   'Sample table rendered correctly'
);

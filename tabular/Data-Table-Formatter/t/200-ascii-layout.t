#!perl -T

use strict;
use warnings;
use Test::More tests => 7;
use Test::Warn;
use Data::Table::Formatter;


### Construct a table with no labels or title
is(
	Data::Table::Formatter::build({
		layout => 'ascii',
		labels => ['one', 'two', 'three'],
		options => {no_labels => 1},
		data => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	}),
	<<__HERE__
   .-------------------------.
   | alpha | bravo | charlie |
   | delta | echo  | foxtrot |
   | golf  | hotel | india   |
   '-------------------------'
__HERE__
,
   'Test table -labels -title rendered correctly'
);


### Construct a table with labels but no title
is(
	Data::Table::Formatter::build({
		layout => 'ascii',
		labels => ['one', 'two', 'three'],
		data => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	}),
	<<__HERE__
   .-------------------------.
   | one   | two   | three   |
   |-------------------------|
   | alpha | bravo | charlie |
   | delta | echo  | foxtrot |
   | golf  | hotel | india   |
   '-------------------------'
__HERE__
,
   'Test table +labels -title rendered correctly'
);


### Construct a table with no labels and with a title
is(
	Data::Table::Formatter::build({
		layout => 'ascii',
		title => 'Sample Data',
		labels => ['one', 'two', 'three'],
		options => {no_labels => 1},
		data => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	}),
	<<__HERE__
   .-------------------------.
   | Sample Data             |
   |-------------------------|
   | alpha | bravo | charlie |
   | delta | echo  | foxtrot |
   | golf  | hotel | india   |
   '-------------------------'
__HERE__
,
   'Test table +labels +title rendered correctly'
);


### Construct a table with labels and a title
is(
	Data::Table::Formatter::build({
		layout => 'ascii',
		title => 'Sample Data',
		labels => ['one', 'two', 'three'],
		data => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	}),
	<<__HERE__
   .-------------------------.
   | Sample Data             |
   |-------------------------|
   | one   | two   | three   |
   |-------------------------|
   | alpha | bravo | charlie |
   | delta | echo  | foxtrot |
   | golf  | hotel | india   |
   '-------------------------'
__HERE__
,
   'Test table -labels +title rendered correctly'
);


### Construct a table with labels wider than the data
is(
	Data::Table::Formatter::build({
		layout => 'ascii',
		title => 'Sample Data',
		labels => ['looooooooooong', 'two', 'three'],
		data => [
			{looooooooooong => 'alpha', two => 'bravo', three => 'charlie'},
			{looooooooooong => 'delta', two => 'echo',  three => 'foxtrot'},
			{looooooooooong => 'golf',  two => 'hotel', three => 'india'},
		]
	}),
	<<__HERE__
   .----------------------------------.
   | Sample Data                      |
   |----------------------------------|
   | looooooooooong | two   | three   |
   |----------------------------------|
   | alpha          | bravo | charlie |
   | delta          | echo  | foxtrot |
   | golf           | hotel | india   |
   '----------------------------------'
__HERE__
,
   'Test table labels > data rendered correctly'
);


### Construct a table with a title wider than the labels
is(
	Data::Table::Formatter::build({
		layout => 'ascii',
		title => 'Looooooooooooooooooooooong title is',
		labels => ['looooong', 'two', 'threeeeee'],
		data => [
			{looooong => 'alpha', two => 'bravo', threeeeee => 'charlie'},
			{looooong => 'delta', two => 'echo',  threeeeee => 'foxtrot'},
			{looooong => 'golf',  two => 'hotel', threeeeee => 'india'},
		]
	}),
	<<__HERE__
   .-------------------------------------.
   | Looooooooooooooooooooooong title is |
   |-------------------------------------|
   | looooong | two   | threeeeee        |
   |-------------------------------------|
   | alpha    | bravo | charlie          |
   | delta    | echo  | foxtrot          |
   | golf     | hotel | india            |
   '-------------------------------------'
__HERE__
,
   'Test table title > labels rendered correctly'
);


### Construct a table with a title wider than the data
is(
	Data::Table::Formatter::build({
		layout => 'ascii',
		title => 'Sample Presentation Data',
		labels => ['one', 'two', 'three'],
		data => [
			{one => 'alpha', two => 'bravo', three => 'charlie'},
			{one => 'delta', two => 'echo',  three => 'foxtrot'},
			{one => 'golf',  two => 'hotel', three => 'india'},
		]
	}),
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
   'Test table title > data rendered correctly'
);





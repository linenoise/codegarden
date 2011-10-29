#!/usr/bin/perl -w
use strict;
use lib qw(Data-Table-Formatter/lib/);
use Data::Table::Formatter;


my $formatter = new Data::Table::Formatter();
$formatter->labels(['one', 'two', 'three']);
$formatter->data([
	{one => 'alpha', two => 'bravo', three => 'charlie'},
	{one => 'delta', two => 'echo',  three => 'foxtrot'},
	{one => 'golf',  two => 'hotel', three => 'india'},
]);
$formatter->layout('ascii');
$formatter->title('Sample Presentation Data');

print $formatter->render();
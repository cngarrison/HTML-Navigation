use strict;
use warnings;

use Test::More tests => 5;
use Data::Printer;

my $ok;

use_ok('HTML::Navigation');

my $items = [
	{ path => 'item/two', label => 'Item Two', order => 2, url => 'two.html' },
	{ path => 'item/one', label => 'Item One', order => 1, url => 'one.html' },
	{
		path     => 'item/four',
		label    => 'Item Four',
		order    => 4,
		children => [{
				path     => 'apple',
				label    => 'Item Apple',
				order    => 1,
				children => [
					{ path => 'pear', label => 'Item Pear', order => 1, url => 'pear.html' },
				]
			},
		]
	}, {
		path     => 'item/three',
		label    => 'Item Three',
		order    => 3,
		children => [
			{ path => 'banana', label => 'Item Banana', order => 2, url => 'banana.html' },
			{ path => 'orange', label => 'Item Orange', order => 1, url => 'orange.html' },
		]
	},
];

ok my $nav = HTML::Navigation->new( items => $items );

my $nav_data = $nav->as_data;
#warn "Dump: \n" . p($nav_data) . "Done!\n";

my $expected_items = [
	{ path => 'item/one', label => 'Item One', order => 1, url => 'one.html' },
	{ path => 'item/two', label => 'Item Two', order => 2, url => 'two.html' },
	{
		path     => 'item/three',
		label    => 'Item Three',
		order    => 3,
		url      => '',
		children => [
			{ path => 'orange', label => 'Item Orange', order => 1, url => 'orange.html' },
			{ path => 'banana', label => 'Item Banana', order => 2, url => 'banana.html' },
		]
	}, {
		path     => 'item/four',
		label    => 'Item Four',
		order    => 4,
		url      => '',
		children => [{
				path     => 'apple',
				label    => 'Item Apple',
				order    => 1,
				url      => '',
				children => [
					{ path => 'pear', label => 'Item Pear', order => 1, url => 'pear.html' },
				]
			},
		]
	},
];

is_deeply(
	$nav_data,
	$expected_items,
	'sorted menu structure',
);

$items = [
	{ path => 'item/bbb', label => 'Item BBB', order => 1, url => 'bbb.html' },
	{ path => 'item/ccc', label => 'Item CCC', order => 1, url => 'ccc.html' },
	{
		path     => 'item/aaa',
		label    => 'Item AAA',
		order    => 1,
		children => [
			{ path => 'child/bbb', label => 'Child BBB', order => 1, url => 'bbb.html' },
			{ path => 'child/aaa', label => 'Child AAA', order => 1, url => 'aaa.html' },
		]
	},
	{ path => 'item/ddd', label => 'Item DDD', order => 1, url => 'ddd.html' },
];

ok $nav = HTML::Navigation->new( items => $items );

$nav_data = $nav->as_data;
#warn "Dump: \n" . p($nav_data) . "Done!\n";

$expected_items = [{
		path     => 'item/aaa',
		label    => 'Item AAA',
		order    => 1,
		url      => '',
		children => [
			{ path => 'child/aaa', label => 'Child AAA', order => 1, url => 'aaa.html' },
			{ path => 'child/bbb', label => 'Child BBB', order => 1, url => 'bbb.html' },
		]
	},
	{ path => 'item/bbb', label => 'Item BBB', order => 1, url => 'bbb.html' },
	{ path => 'item/ccc', label => 'Item CCC', order => 1, url => 'ccc.html' },
	{ path => 'item/ddd', label => 'Item DDD', order => 1, url => 'ddd.html' },
];

is_deeply(
	$nav_data,
	$expected_items,
	'sorted menu structure, by path',
);

1;

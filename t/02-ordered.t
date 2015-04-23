use strict;
use warnings;

use Test::More tests => 5;
use Data::Printer;

my $ok;

use_ok('HTML::Navigation');

my $items = [
	{ path => 'item/two', label => 'Item Two', order => 2 },
	{ path => 'item/one', label => 'Item One', order => 1 },
	{
		path     => 'item/four',
		label    => 'Item Four',
		order    => 4,
		children => [{
				path     => 'apple',
				label    => 'Item Apple',
				order    => 1,
				children => [
					{ path => 'pear', label => 'Item Pear', order => 1 },
				]
			},
		]
	}, {
		path     => 'item/three',
		label    => 'Item Three',
		order    => 3,
		children => [
			{ path => 'banana', label => 'Item Banana', order => 2 },
			{ path => 'orange', label => 'Item Orange', order => 1 },
		]
	},
];

ok my $nav = HTML::Navigation->new( items => $items );

my $nav_data = $nav->as_data;
#warn "Dump: \n" . p($nav_data) . "Done!\n";

my $expected_items = [
	{ path => 'item/one', label => 'Item One', order => 1, url => '' },
	{ path => 'item/two', label => 'Item Two', order => 2, url => '' },
	{
		path     => 'item/three',
		label    => 'Item Three',
		order    => 3,
		url      => '',
		children => [
			{ path => 'orange', label => 'Item Orange', order => 1, url => '' },
			{ path => 'banana', label => 'Item Banana', order => 2, url => '' },
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
					{ path => 'pear', label => 'Item Pear', order => 1, url => '' },
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
	{ path => 'item/bbb', label => 'Item BBB', order => 1 },
	{ path => 'item/ccc', label => 'Item CCC', order => 1 },
	{
		path     => 'item/aaa',
		label    => 'Item AAA',
		order    => 1,
		children => [
			{ path => 'child/bbb', label => 'Child BBB', order => 1, url => '' },
			{ path => 'child/aaa', label => 'Child AAA', order => 1, url => '' },
		]
	},
	{ path => 'item/ddd', label => 'Item DDD', order => 1 },
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
			{ path => 'child/aaa', label => 'Child AAA', order => 1, url => '' },
			{ path => 'child/bbb', label => 'Child BBB', order => 1, url => '' },
		]
	},
	{ path => 'item/bbb', label => 'Item BBB', order => 1, url => '' },
	{ path => 'item/ccc', label => 'Item CCC', order => 1, url => '' },
	{ path => 'item/ddd', label => 'Item DDD', order => 1, url => '' },
];

is_deeply(
	$nav_data,
	$expected_items,
	'sorted menu structure, by path',
);

1;

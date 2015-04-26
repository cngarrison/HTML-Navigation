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
	{ path => 'item/one', label => 'Item One', order => 1, url => 'one.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
	{ path => 'item/two', label => 'Item Two', order => 2, url => 'two.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
	{
		path     => 'item/three',
		label    => 'Item Three',
		order    => 3,
		url      => '', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[],
		children => [
			{ path => 'orange', label => 'Item Orange', order => 1, url => 'orange.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
			{ path => 'banana', label => 'Item Banana', order => 2, url => 'banana.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
		]
	}, {
		path     => 'item/four',
		label    => 'Item Four',
		order    => 4,
		url      => '', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[],
		children => [{
				path     => 'apple',
				label    => 'Item Apple',
				order    => 1,
				url      => '', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[],
				children => [
					{ path => 'pear', label => 'Item Pear', order => 1, url => 'pear.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
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
	{ path => 'item/bbb', label => 'Item BBB', order => 1, url => 'bbb.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
	{ path => 'item/ccc', label => 'Item CCC', order => 1, url => 'ccc.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
	{
		path     => 'item/aaa',
		label    => 'Item AAA',
		order    => 1, is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[],
		children => [
			{ path => 'child/bbb', label => 'Child BBB', order => 1, url => 'bbb.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
			{ path => 'child/aaa', label => 'Child AAA', order => 1, url => 'aaa.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
		]
	},
	{ path => 'item/ddd', label => 'Item DDD', order => 1, url => 'ddd.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
];

ok $nav = HTML::Navigation->new( items => $items );

$nav_data = $nav->as_data;
#warn "Dump: \n" . p($nav_data) . "Done!\n";

$expected_items = [{
		path     => 'item/aaa',
		label    => 'Item AAA',
		order    => 1,
		url      => '', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[],
		children => [
			{ path => 'child/aaa', label => 'Child AAA', order => 1, url => 'aaa.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
			{ path => 'child/bbb', label => 'Child BBB', order => 1, url => 'bbb.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
		]
	},
	{ path => 'item/bbb', label => 'Item BBB', order => 1, url => 'bbb.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
	{ path => 'item/ccc', label => 'Item CCC', order => 1, url => 'ccc.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
	{ path => 'item/ddd', label => 'Item DDD', order => 1, url => 'ddd.html', is_active => 0, dom_id => undef, description => undef, icon => undef, css_classes=>[] },
];

is_deeply(
	$nav_data,
	$expected_items,
	'sorted menu structure, by path',
);

1;

use strict;
use warnings;

use Test::More tests => 3;
use Data::Printer;

my $ok;

use_ok('HTML::Navigation');

my $items = [
	{ path => 'item/one', label => 'Item One', url => 'one.html' },
	{ path => 'item/two', label => 'Item Two', url => 'two.html' },
	{
		path     => 'item/three',
		label    => 'Item Three',
		children => [
			{ path => 'orange', label => 'Item Orange', url => 'orange.html' },
			{ path => 'banana', label => 'Item Banana', url => 'banana.html' },
		]
	}, {
		path     => 'item/four',
		label    => 'Item Four',
		children => [{
				path     => 'apple',
				label    => 'Item Apple',
				children => [
					{ path => 'pear', label => 'Item Pear', url => 'pear.html' },
				]
			},
		]
	},
];

ok my $nav = HTML::Navigation->new( items => $items, no_sorting => 1 );

#warn "Dump: \n" . $nav->stringify . "Done!\n";
# my $nav_output = $nav->stringify;
# my $expected   = q{path: item/one, label: Item One, order: 0, url:
# path: item/two, label: Item Two, order: 0, url:
# path: item/three, label: Item Three, order: 0, url:
# 	path: orange, label: Item Orange, order: 0, url:
# path: item/four, label: Item Four, order: 0, url:
# 	path: apple, label: Item Apple, order: 0, url:
# 		path: pear, label: Item Pear, order: 0, url:
# };
#
# is( $nav_output, $expected, 'content is correct' );


my $nav_data = $nav->as_data;
#warn "Dump: \n" . p($nav_data) . "Done!\n";

my $expected_items = [
	{ path => 'item/one', label => 'Item One', order => 0, url => 'one.html' },
	{ path => 'item/two', label => 'Item Two', order => 0, url => 'two.html' },
	{
		path     => 'item/three',
		label    => 'Item Three',
		order    => 0,
		url      => '',
		children => [
			{ path => 'orange', label => 'Item Orange', order => 0, url => 'orange.html' },
			{ path => 'banana', label => 'Item Banana', order => 0, url => 'banana.html' },
		]
	}, {
		path     => 'item/four',
		label    => 'Item Four',
		order    => 0,
		url      => '',
		children => [{
				path     => 'apple',
				label    => 'Item Apple',
				order    => 0,
				url      => '',
				children => [
					{ path => 'pear', label => 'Item Pear', order => 0, url => 'pear.html' },
				]
			},
		]
	},
];

is_deeply(
	$nav_data,
	$expected_items,
	'nested menu structure',
);

1;

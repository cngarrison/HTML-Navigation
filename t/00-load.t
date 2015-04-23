#!perl -wT

use strict;
use warnings;

use Test::More tests => 2;

use_ok( 'HTML::Navigation' );
use_ok( 'HTML::Navigation::Item' );

diag( 'HTML::Navigation '
            . $HTML::Navigation::VERSION );
diag( 'HTML::Navigation::Item '
            . $HTML::Navigation::Item::VERSION );

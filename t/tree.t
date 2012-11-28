use strict;
use warnings;
use Test::More;
use t::TestData;
our %objects;

use Glow::Object::Tree;

is( Glow::Mapper->kind2class('tree'),
    'Glow::Object::Tree', 'tree => Glow::Object::Tree' );

test_tree($_) for @{ $objects{tree} };

done_testing;


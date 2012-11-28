use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Tag;
is( Glow::Mapper->kind2class('tag'),
    'Glow::Object::Tag', 'tag => Glow::Object::Tag' );

test_tag($_) for @{ $objects{tag} };

done_testing;


use strict;
use warnings;
use Test::More;
use t::TestData;
our %objects;

use Glow::Object::Commit;

is( Glow::Mapper->kind2class('commit'),
    'Glow::Object::Commit', 'commit => Glow::Object::Commit' );

test_commit($_) for @{ $objects{commit} };

done_testing;

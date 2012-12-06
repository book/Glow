package Glow::Storage::Loose;
use Moose;

extends 'Glow::Storage';

with 'Glow::Role::Storage::Loose' => {
    algorithm => 'SHA-1',
    kind2class =>
        { map { lc $_ => "Glow::Object::$_" } qw( Blob Tree Commit Tag ) }
};

1;


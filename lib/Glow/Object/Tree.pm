package Glow::Object::Tree;
use Moose;

with 'Glow::Role::Tree';
with 'Glow::Role::Digest' => { algorithm => 'SHA-1' };

sub kind {'tree'}

1;


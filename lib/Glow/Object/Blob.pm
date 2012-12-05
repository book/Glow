package Glow::Object::Blob;
use Moose;

with 'Glow::Role::Blob';
with 'Glow::Role::Digest' => { algorithm => 'SHA-1' };

sub kind {'blob'}

1;


package Glow::Object::Blob;
use Moose;

with 'Glow::Role::Blob';
with 'Glow::Role::Digest' => { algorithm => 'SHA-1' };

sub kind {'blob'}

__PACKAGE__->register_mapping;

1;


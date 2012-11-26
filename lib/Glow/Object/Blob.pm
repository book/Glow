package Glow::Object::Blob;
use Moose;

with 'Glow::Role::Blob';

sub kind {'blob'}

__PACKAGE__->register_mapping;

1;


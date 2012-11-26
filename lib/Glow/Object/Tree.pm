package Glow::Object::Tree;
use Moose;

with 'Glow::Role::Tree';

sub kind {'tree'}

__PACKAGE__->register_mapping;

1;


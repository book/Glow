package Glow::Object::Tag;
use Moose;

with 'Glow::Role::Tag';

sub kind {'tag'}

__PACKAGE__->register_mapping;

1;


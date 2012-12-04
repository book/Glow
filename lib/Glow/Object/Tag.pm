package Glow::Object::Tag;
use Moose;

with 'Glow::Role::Tag';
with 'Glow::Role::Digest' => { algorithm => 'SHA-1' };

sub kind {'tag'}

__PACKAGE__->register_mapping;

1;


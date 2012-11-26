package Glow::Object::Commit;
use Moose;

with 'Glow::Role::Commit';

sub kind {'commit'}

__PACKAGE__->register_mapping;

1;


package Glow::Role::Storage;

use Moose::Role;

requires qw( has_object get_object put_object );

has readonly => (
    is       => 'ro',
    isa      => 'Bool',
    required => 1,
    lazy     => 1,
    builder  => '_build_readonly',
);

1;

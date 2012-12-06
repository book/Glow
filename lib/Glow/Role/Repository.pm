package Glow::Role::Repository;
use Moose::Role;
use MooseX::Types::Path::Class;

has 'directory' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    required => 1,
    coerce   => 1,
);

1;

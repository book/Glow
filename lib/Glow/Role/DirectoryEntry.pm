package Glow::Role::DirectoryEntry;
use Moose::Role;

requires qw( as_content as_string );

has 'filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'digest'   => ( is => 'ro', isa => 'Str', required => 1 );

1;

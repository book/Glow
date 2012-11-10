package Glow::Role::DirectoryEntry;
use Moose::Role;

has 'mode'     => ( is => 'ro', isa => 'Str', required => 1 );
has 'filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'sha1'     => ( is => 'ro', isa => 'Str', required => 1 );

1;


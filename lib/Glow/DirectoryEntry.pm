package Glow::DirectoryEntry;

use Moose;
use namespace::autoclean;

with 'Glow::Role::DirectoryEntry';

__PACKAGE__->meta->make_immutable;

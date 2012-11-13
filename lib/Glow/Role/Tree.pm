package Glow::Role::Tree;
use Moose::Role;
use Carp;

with 'Glow::Role::Object';
with 'Glow::Role::ContentBuilder::FromDirectoryEntries';

1;

package Glow::Role::DirectoryEntry;
use Moose::Role;

requires qw( as_content as_string );

has 'filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'digest'   => ( is => 'ro', isa => 'Str', required => 1 );

1;

# ABSTRACT: A role representing the core that a directory entry does

=head1 SYNOPSIS

    package Glow::Repository::Git::DirectoryEntry;

    use Moose;

    with 'Glow::Role::DirectoryEntry';

    has mode => ( is => 'ro', isa => 'Str', required => 1 );

    # these methods are required by Glow::Role::DirectoryEntry
    sub as_content {...}
    sub as_string  {...}

    1;

=head1 DESCRIPTION

This role defines the minimum set of attributes for a I<directory entry>.

The L<Glow::Role::ContentBuilder::FromDirectoryEntries> will create content
from an array of object doing L<Glow::Role::DirectoryEntry>.

The consuming class may add new attributes (e.g. a Git directory entry has
a C<mode>attribute, see L<Glow::Repository::Git::DirectoryEntry>), and
I<must> define the C<as_content()> and C<as_string()> methods.

=attr filename

The filename of the object, relative to the current I<tree>.

=attr digest

The object digest.

=head1 REQUIRED METHODS

=head2 as_content

Returns a string representation of the directory entry as stored
in a tree object.

This is used by L<Glow::Role::ContentBuilder::FromDirectoryEntries>
to build the content from a list of L<Glow::Roles::DirectoryEntry>
objects.

=head2 as_string

Returns a user-readable string representation of the directory entry.

=cut

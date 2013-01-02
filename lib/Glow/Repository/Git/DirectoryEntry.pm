package Glow::Repository::Git::DirectoryEntry;

use Moose;

with 'Glow::Role::DirectoryEntry';

# Git only uses the following (octal) modes:
# - 040000 for subdirectory (tree)
# - 100644 for file (blob)
# - 100755 for executable (blob)
# - 120000 for a blob that specifies the path of a symlink
# - 160000 for submodule (commit)
#
# See also: cache.h in git.git
has mode => ( is => 'ro', isa => 'Str', required => 1 );

sub as_content {
    my ($self) = @_;
    return
          $self->mode . ' '
        . $self->filename . "\0"
        . pack( 'H*', $self->digest );
}

sub as_string {
    my ($self) = @_;
    my $mode = oct( '0' . $_->mode );
    return sprintf "%06o %s %s\t%s\n", $mode,
        $mode & 0100000 ? 'blob' : 'tree',
        $self->digest, $self->filename;
}

1;

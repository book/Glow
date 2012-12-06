package Glow::Role::Tree;
use Moose::Role;

with 'Glow::Role::Object' => { -excludes => [ 'as_string' ] };
with 'Glow::Role::ContentBuilder::FromDirectoryEntries';

sub as_string {
    my ($self) = @_;
    return join '', map {
        my $mode = oct( '0' . $_->mode );
        sprintf "%06o %s %s\t%s\n", $mode, $mode & 0100000 ? 'blob' : 'tree',
            $_->digest, $_->filename
    } $self->directory_entries;
}

1;

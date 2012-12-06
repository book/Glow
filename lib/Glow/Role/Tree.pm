package Glow::Role::Tree;
use Moose::Role;

with 'Glow::Role::Object' => { -excludes => [ 'as_string' ] };
with 'Glow::Role::ContentBuilder::FromDirectoryEntries';

sub as_string {
    my ($self) = @_;
    return join '', map $_->as_string, $self->directory_entries;
}

1;

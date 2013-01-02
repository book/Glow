package Glow::Role::ContentBuilder::FromDirectoryEntries;
use Moose::Role;

with 'Glow::Role::ContentBuilder';

requires '_build_directory_entries';

has directory_entries => (
    is          => 'ro',
    isa         => 'ArrayRef[Glow::Role::DirectoryEntry]',
    lazy        => 1,
    required    => 0,
    predicate   => 'has_directory_entries',
    builder     => '_build_directory_entries',
    auto_deref  => 1,
    trigger     => sub { $_[0]->_content_from_trigger('directory_entries'); },
    initializer => sub {
        my ( $self, $entries, $writer ) = @_;
        $writer->( [ sort { $a->filename cmp $b->filename } @$entries ] );
    },
);

sub _build_fh_using_directory_entries {
    my ($self) = @_;
    return IO::String->new( join '', map $_->as_content, $self->directory_entries );
};

1;

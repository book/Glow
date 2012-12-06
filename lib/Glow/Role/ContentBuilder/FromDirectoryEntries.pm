package Glow::Role::ContentBuilder::FromDirectoryEntries;
use Moose::Role;

use Glow::DirectoryEntry;

requires '_content_from_trigger';

has directory_entries => (
    is          => 'ro',
    isa         => 'ArrayRef[Glow::DirectoryEntry]',
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

sub _build_directory_entries {
    my $self    = shift;
    my $content = $self->content;
    return [] unless $content;

    my @directory_entries;
    while ($content) {
        my $space_index = index( $content, ' ' );
        my $mode = substr( $content, 0, $space_index );
        $content = substr( $content, $space_index + 1 );
        my $null_index = index( $content, "\0" );
        my $filename = substr( $content, 0, $null_index );
        $content = substr( $content, $null_index + 1 );
        my $digest = unpack( 'H*', substr( $content, 0, 20 ) );
        $content = substr( $content, 20 );
        push @directory_entries,
            Glow::DirectoryEntry->new(
            mode     => $mode,
            filename => $filename,
            digest   => $digest,
            );
    }
    return \@directory_entries;
}

sub _build_fh_using_directory_entries {
    my ($self) = @_;
    return IO::String->new( join '', map $_->as_content, $self->directory_entries );
};

1;

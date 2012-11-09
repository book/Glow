package Glow::Role::Tree;
use Moose::Role;
use Carp;

with 'Glow::Role::Object';

has directory_entries => (
    is         => 'ro',
    isa        => 'ArrayRef[Glow::DirectoryEntry]',
    lazy_build => 1,
    auto_deref => 1,
);

# we can only pass one of 'content' or 'content_source' or 'directory_entries'
around BUILD => sub {
    my ($orig, $self) = @_;
    croak
        "At least one but only one of attributes content, content_source or directory_entries is required"
        if $self->has_content 
            + $self->has_content_source
            + $self->has_directory_entries != 1;
};

# builders
around _build_content => sub {
    my $orig = shift;
    my $self = shift;
    if ( $self->has_directory_entries ) {
        my $content = '';
        foreach my $de ( $self->directory_entries ) {
            $content
                .= $de->mode . ' '
                . $de->filename . "\0"
                . pack( 'H*', $de->sha1 );
        }
        return $content;
    }
    $self->$orig;
};

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
        my $sha1 = unpack( 'H*', substr( $content, 0, 20 ) );
        $content = substr( $content, 20 );
        push @directory_entries,
            Glow::DirectoryEntry->new(
            mode     => $mode,
            filename => $filename,
            sha1     => $sha1,
            );
    }
    return \@directory_entries;
}

1;

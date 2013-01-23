package Glow::Repository::Git::Tree;

use Moose;

with 'Glow::Role::Tree',
    'Glow::Role::Digest' => { algorithm => 'SHA-1' },
    'Glow::Role::ContentBuilder::FromGit';

sub kind {'tree'}

*sha1 = \&digest;

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
            Glow::Repository::Git::DirectoryEntry->new(
            mode     => $mode,
            filename => $filename,
            digest   => $digest,
            );
    }
    return \@directory_entries;
}

__PACKAGE__->meta->make_immutable;

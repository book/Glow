package Glow::Repository::Git;

use Moose;
use namespace::autoclean;
use Path::Class::Dir ();

use Glow::Repository::Git::Config;
use Glow::Repository::Git::Storage::Loose;
use Glow::Repository::Git::Storage::Pack;
use Glow::Repository::Git::DirectoryEntry;
use Glow::Repository::Git::Blob;
use Glow::Repository::Git::Tree;
use Glow::Repository::Git::Commit;
use Glow::Repository::Git::Tag;

with 'Glow::Role::Repository';

has '+config' => ( isa => 'Glow::Repository::Git::Config' );

# builder methods
sub _build_config {
    my ($self) = @_;
    return Glow::Repository::Git::Config->new( repository => $self );
}

sub _build_object_store {
    my ($self) = @_;
    my @stores;
    my $dir = Path::Class::Dir->new( $self->directory, 'objects', 'pack' );

    # packs
    if ( -e $dir ) {
        push @stores,
            Glow::Store->new(
            readonly => 1,
            stores   => [
                map Glow::Repository::Git::Storage::Pack->new(
                    filename => $_
                ),
                grep $_ =~ /\.pack$/,
                $dir->children
            ],
            );
    }

    # loose
    push @stores,
        Glow::Repository::Git::Storage::Loose->new(
        directory => Path::Class::Dir->new( $self->directory, 'objects' ) );

    # full store
    return Glow::Store->new( stores => \@stores );
}

__PACKAGE__->meta->make_immutable;

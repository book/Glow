package Glow::Repository::Git;

use Moose;
use namespace::autoclean;
use Path::Class::Dir ();

use Glow::Repository::Git::Config;
use Glow::Repository::Git::Storage::Pack;
use Glow::Repository::Git::DirectoryEntry;

with 'Glow::Role::Repository';

has '+config' => ( isa => 'Glow::Repository::Git::Config' );

# build specific classes needed to handle Git repositories
{
    my $kind2class = {};

    # special method for the Tree class
    sub Glow::Repository::Git::Object::Tree::_build_directory_entries;  # stub
    my $bde = sub {
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
    };

    # the classes for the objects
    for my $kind (qw( blob tree commit tag )) {
        my $Kind  = ucfirst $kind;
        my $class = "Glow::Repository::Git::Object::$Kind";

        Moose::Meta::Class->create(
            $class,
            superclasses => ['Moose::Object'],
            roles        => [
                "Glow::Role::$Kind",
                'Glow::Role::Digest' => { algorithm => 'SHA-1', },
                'Glow::Role::ContentBuilder::FromGit',
            ],
            methods => {
                kind => sub {$kind},
                sha1 => sub { $_[0]->digest },    # alias
                ( _build_directory_entries => $bde )x!! ( $kind eq 'tree' ),
            },
        );

        # register kind to class mapping
        $kind2class->{$kind} = $class;

        # make immutable
        $class->meta->make_immutable;
    }

    # the loose storage class
    Moose::Meta::Class->create(
        'Glow::Repository::Git::Storage::Loose',
        superclasses => ['Moose::Object'],
        roles        => [
            'Glow::Role::Storage::Loose' => {
                algorithm  => 'SHA-1',
                kind2class => $kind2class,
            },
        ],
    );
    Glow::Repository::Git::Storage::Loose->meta->make_immutable;

}

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

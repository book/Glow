package Glow::Repository::Git;

use Moose;
use namespace::autoclean;
use Path::Class::Dir ();

use Glow::Repository::Git::Config;
use Glow::Repository::Git::Storage::Pack;

with 'Glow::Role::Repository';

has '+config' => ( isa => 'Glow::Repository::Git::Config' );

# build specific classes needed to handle Git repositories
{
    my $kind2class = {};

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
            ],
            methods => {
                kind => sub {$kind},
                sha1 => sub { $_[0]->digest },    # alias
            },
        );

        # register kind to class mapping
        $kind2class->{$kind} = $class;
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
}

# builder methods
sub _build_config {
    my ($self) = @_;
    return Glow::Repository::Git::Config->new( repository => $self );
}

sub _build_object_store {
    my ($self) = @_;
    my @pack_store;
    my $pack_dir
        = Path::Class::Dir->new( $self->directory, 'objects', 'pack' );

    # packs
    if ( -e $pack_dir ) {
        push @pack_store,
            Glow::Store->new(
            readonly => 1,
            stores   => [
                map Glow::Repository::Git::Storage::Pack->new(
                    filename => $_
                ),
                grep $_ =~ /\.pack$/,
                $pack_dir->children
            ],
            );
    }

    # loose
    push @pack_store,
        Glow::Repository::Git::Storage::Loose->new(
        directory => Path::Class::Dir->new( $self->directory, 'objects' ) );

    # full store
    return Glow::Store->new( stores => \@pack_store );
}

__PACKAGE__->meta->make_immutable;

package Glow::Role::Repository;
use Moose::Role;
use MooseX::Types::Path::Class;

use Glow::Config;

requires qw( _build_objects_stores );

has 'directory' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    required => 1,
    coerce   => 1,
);

has 'config' => (
    is       => 'ro',
    isa      => 'Glow::Config',
    required => 0,
    lazy     => 1,
    builder  => '_build_config',
);

has 'objects_stores' => (
    is         => 'ro',
    isa        => 'ArrayRef[Glow::Storage]',
    required   => 0,
    lazy       => 1,
    builder    => '_build_objects_stores',
    auto_deref => 1,
);

sub _build_config {
    my ($self) = @_;
    return Glow::Config->new( repository => $self );
}

sub get_object {
    my ( $self, $digest ) = @_;
    for my $store ( $self->objects_stores ) {
        my $object = $store->get_object($digest);
        return $object if $object;
    }
    return;    # found nothing
}

sub put_object {
    my ( $self, $object ) = @_;
    my ($store) = grep $_->can('put_object'), $self->objects_stores;
    die "No object store to store ${\$object->digest}" if !$store;
    $store->put_object($object);
}

1;

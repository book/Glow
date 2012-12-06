package Glow::Role::Repository;
use Moose::Role;
use MooseX::Types::Path::Class;

requires qw( _build_objects_stores );

has 'directory' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    required => 1,
    coerce   => 1,
);

has 'objects_stores' => (
    is         => 'ro',
    isa        => 'ArrayRef[Glow::Storage]',
    required   => 0,
    lazy       => 1,
    builder    => '_build_objects_stores',
    auto_deref => 1,
);

sub get_object {
    my ( $self, $digest ) = @_;
    my $object;
    for my $store ( $self->objects_stores ) {
        $object = $store->get_object($digest);
        return $object if $object;
    }
    return $object;
}

sub put_object {
    my ( $self, $object ) = @_;
    my ($store) = grep $_->can('put_object'), $self->objects_stores;
    die "No object store to store ${\$object->digest}" if !$store;
    $store->put_object($object);
}

1;

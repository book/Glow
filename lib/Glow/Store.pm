package Glow::Store;

use Moose;

use Glow::Role::Storage;
use List::Util qw( sum );

has stores => (
    is  => 'ro',
    isa => 'ArrayRef[Glow::Role::Storage]',
    required => 1,
    auto_deref => 1,
);

# a Glow::Store is a collection of objects doing Glow::Role::Storage

sub has_object {
    my ( $self, $digest ) = @_;
    $_->has_object($digest) and return 1
        for $self->stores;
    return '';
}

sub get_object {
    my ( $self, $digest ) = @_;
    for my $store ( $self->stores ) {
        my $object = $store->get_object($digest);
        return $object if $object;
    }
    return;    # found nothing
}

sub put_object {
    my ( $self, $object ) = @_;

    # it's already there, no need to save it again
    return 1 if $self->has_object( $object->digest );

    # try all stores until one actually saves it
    $_->put_object($object) and return 1
        for $self->stores;
    return '';
}

sub delete_object {
    my ( $self, $digest ) = @_;
    return sum map $_->delete_object($digest), $self->stores;
}

1;

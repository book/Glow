package Glow::Store;

use Moose;
use namespace::autoclean;
use List::Util qw( sum );

with 'Glow::Role::Storage';

has stores => (
    is         => 'ro',
    isa        => 'ArrayRef[Glow::Role::Storage]',
    required   => 1,
    auto_deref => 1,
);

# a Glow::Store is a collection of objects doing Glow::Role::Storage

sub _build_readonly {
    my ($self) = @_;

    # it's only readonly if all storage inside is readonly
    return !scalar grep !$_->readonly, $self->stores;
}

sub has_object {
    my ( $self, $digest ) = @_;
    $_->has_object($digest) and return 1 for $self->stores;
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
        for grep !$_->readonly, $self->stores;
    return '';
}

sub delete_object {
    my ( $self, $digest ) = @_;
    return sum map $_->delete_object($digest), grep !$_->readonly,
        $self->stores;
}

__PACKAGE__->meta->make_immutable;

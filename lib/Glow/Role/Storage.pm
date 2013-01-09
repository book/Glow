package Glow::Role::Storage;

use Moose::Role;

requires qw( _build_readonly has_object get_object put_object delete_object );

has readonly => (
    is       => 'ro',
    isa      => 'Bool',
    required => 1,
    lazy     => 1,
    builder  => '_build_readonly',
);

1;

# ABSTRACT: A role for Glow storage objects

=head1 SYNOPSIS

    # example in-memory store using a hash

    package Glow::Storage::InMemory;

    use Moose;

    with 'Glow::Role::Storage';

    has store => ( is => 'ro', isa => 'HashRef', default => sub { {} } );

    sub _build_readonly {''}

    sub has_object {
        my ( $self, $digest ) = @_;
        return exists $self->store->{$digest};
    }

    sub get_object {
        my ( $self, $digest ) = @_;
        return $self->store->{$digest};
    }

    sub put_object {
        my ( $self, $object ) = @_;
        return $self->store->{ $object->digest } = $object;
    }

    sub delete_object {
        my ( $self, $digest ) = @_;
        return !!delete $self->store->{$digest};
    }

    __PACKAGE__->meta->make_immutable;

=head1 DESCRIPTION

The L<Glow::Role::Storage> role defines the methods and attributes
that a storage class must implement to be usable by classes doing
the L<Glow::Role::Repository> role.

=head1 REQUIRED METHODS

=head2 _build_readonly

A builder for the C<readonly> attribute.

=head2  has_object( $digest )

Return a boolean value indicating if this store contains the object
referenced by C<$digest>.

=head2 get_object( $digest )

Return the object referenced by C<$digest>, or C<undef> if the store
does not hold the object.

=head2 put_object( $object )

Try to store the given C<$object> in the store. Return a boolean value
indicating the success of the operation.

=head2 delete_object( $digest )

Try to delete the object referenced by C<$digest> from the store.
Return true if the object was successfullly deleted, and false if the
object was not deleted (either because it wasn't there or because the
deletion failed).

=attr readonly

Defines if the storage object is read-only.

=cut

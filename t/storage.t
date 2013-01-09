package TestGlow::Storage::InMemory;
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

package TestGlow::Object::Blob;
use Moose;
with 'Glow::Role::Blob', 'Glow::Role::Digest' => { algorithm => 'SHA-256' };

sub kind {'BLOB'}

__PACKAGE__->meta->make_immutable;

package main;
use strict;
use warnings;
use Test::More;

my $store = TestGlow::Storage::InMemory->new();
my $blob = TestGlow::Object::Blob->new( content => 'hello' );
is( $blob->kind, 'BLOB', 'kind' );
is( $blob->digest,
    '058e82dad3c59b9faf06ccf45761b5f5228e4e7bf6eb53a7324dcbc0a3bd075c',
    'digest' );
is( $blob->size,    5,       'size' );
is( $blob->content, 'hello', 'content' );

ok( !$store->has_object( $blob->digest ),    'blob not in store' );
ok( !$store->delete_object( $blob->digest ), 'absent object not deleted' );
ok( !$store->get_object( $blob->digest ),    'blob not in store' );
ok( $store->put_object($blob),               'blob stored' );
ok( $store->has_object( $blob->digest ),     'blob in store' );

my $object = $store->get_object( $blob->digest );
is( $object->digest,  $blob->digest,  'same digest' );
is( $object->size,    $blob->size,    'same size' );
is( $object->content, $blob->content, 'same content' );

ok( $store->delete_object( $blob->digest ),  'object deleted' );
ok( !$store->has_object( $blob->digest ),    'blob not in store' );
ok( !$store->delete_object( $blob->digest ), 'absent object not deleted' );

done_testing;

package Glow::Object::Blob;
use Moose;

with 'Glow::Role::Blob';

sub kind { 'blob' }

__PACKAGE__->meta->make_immutable;


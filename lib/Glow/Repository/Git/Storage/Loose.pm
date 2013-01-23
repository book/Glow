package Glow::Repository::Git::Storage::Loose;

use Moose;

with 'Glow::Repository::Git::Storage',
    'Glow::Role::Storage::Loose' => { algorithm => 'SHA-1' };

__PACKAGE__->meta->make_immutable;

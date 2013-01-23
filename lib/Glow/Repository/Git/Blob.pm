package Glow::Repository::Git::Blob;

use Moose;

with 'Glow::Role::Object',
    'Glow::Role::Digest' => { algorithm => 'SHA-1' },
    'Glow::Role::ContentBuilder::FromGit';

sub kind {'blob'}

*sha1 = \&digest;

__PACKAGE__->meta->make_immutable;

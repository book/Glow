package Glow::Repository::Git::Tag;

use Moose;

with 'Glow::Role::Tag',
    'Glow::Role::Digest' => { algorithm => 'SHA-1' },
    'Glow::Role::ContentBuilder::FromGit';

sub kind {'tag'}

*sha1 = \&digest;

__PACKAGE__->meta->make_immutable;

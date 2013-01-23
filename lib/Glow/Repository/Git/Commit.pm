package Glow::Repository::Git::Commit;

use Moose;

with 'Glow::Role::Commit',
    'Glow::Role::Digest' => { algorithm => 'SHA-1' },
    'Glow::Role::ContentBuilder::FromGit';

sub kind {'commit'}

*sha1 = \&digest;

__PACKAGE__->meta->make_immutable;

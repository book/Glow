package Glow::Repository::Git::Storage::Loose;

use Moose;

with 'Glow::Role::Storage::Loose' => {
    algorithm  => 'SHA-1',
    kind2class => {
        blob   => 'Glow::Repository::Git::Blob',
        tree   => 'Glow::Repository::Git::Tree',
        commit => 'Glow::Repository::Git::Commit',
        tag    => 'Glow::Repository::Git::Tag',
    },
};

__PACKAGE__->meta->make_immutable;

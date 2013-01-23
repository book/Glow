package Glow::Repository::Git::Storage;

use Moose::Role;

with 'Glow::Role::Storage';

my %kind2class = (
    blob   => 'Glow::Repository::Git::Blob',
    tree   => 'Glow::Repository::Git::Tree',
    commit => 'Glow::Repository::Git::Commit',
    tag    => 'Glow::Repository::Git::Tag',
);

sub kind2class { $kind2class{ $_[1] } }

1;

package Glow::Config;

use Moose;
use namespace::autoclean;

extends 'Config::GitLike';

has '+confname' => ( default => 'glowconfig', );
has 'repository' => (
    is       => 'ro',
    does     => 'Glow::Role::Repository',
    required => 1,
    weak_ref => 1
);

override dir_file => sub {
    my ($self) = @_;
    return $self->repository->directory->file('config');
};

__PACKAGE__->meta->make_immutable;

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

# ABSTRACT: Config::GitLike subclass for use with Glow

=pod

=head1 SYNOPSIS

    # $r does Glow::Role::Repository
    my $config = $r->config;

    # Glow::Config extends Config::GitLike
    $config->get( key => 'glow.class' );

=head1 DESCRIPTION

L<Glow::Config> is a class to manage L<Glow> configuration. It extends
L<Config::GitLike> to use a specific name for the configuration file,
and point back to its L<Glow::Repository> object.

=attr repository

A (weak) link back to the L<Glow::Repository> object the configuration
belongs to.

=cut

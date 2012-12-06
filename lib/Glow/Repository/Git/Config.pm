package Glow::Repository::Git::Config;

use Moose;
use namespace::autoclean;

extends 'Glow::Config';

has '+confname' => ( default => 'gitconfig' );

__PACKAGE__->meta->make_immutable;

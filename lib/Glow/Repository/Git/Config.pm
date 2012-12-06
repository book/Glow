package Glow::Repository::Git::Config;

use Moose;

extends 'Glow::Config';

has '+confname' => ( default => 'gitconfig' );

1;


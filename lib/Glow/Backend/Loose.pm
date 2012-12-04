package Glow::Backend::Loose;
use Moose;

with 'Glow::Role::Backend::Loose' => { algorithm => 'SHA-1' };

1;


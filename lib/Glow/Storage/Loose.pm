package Glow::Storage::Loose;
use Moose;

with 'Glow::Role::Storage::Loose' => { algorithm => 'SHA-1' };

1;


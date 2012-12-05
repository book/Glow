package Glow::Object::Commit;
use Moose;

with 'Glow::Role::Commit';
with 'Glow::Role::Digest' => { algorithm => 'SHA-1' };

sub kind {'commit'}

1;


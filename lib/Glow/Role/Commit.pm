package Glow::Role::Commit;
use Moose::Role;

with 'Glow::Role::Object';
with 'Glow::Role::ContentBuilder::FromCommitInfo';

1;

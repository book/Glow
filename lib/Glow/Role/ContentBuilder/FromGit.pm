package Glow::Role::ContentBuilder::FromGit;
use Moose::Role;

requires '_content_from_trigger';

has git => (
    is       => 'ro',
    isa      => 'Git::Repository',
    required => 0,
    trigger  => sub { $_[0]->_content_from_trigger('git') },
);

# at this point Git::Repository should have been loaded
sub _build_fh_using_git {
    my ($self) = @_;
    $self->git->command( 'cat-file', $self->kind, $self->sha1 )->stdout;
}

1;

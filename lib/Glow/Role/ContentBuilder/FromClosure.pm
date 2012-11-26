package Glow::Role::ContentBuilder::FromClosure;
use Moose::Role;

requires '_content_from_trigger';

has content_fh_from_closure => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 0,
    trigger  => sub { $_[0]->_content_from_trigger('content_fh_from_closure'); },
);

sub _build_fh_using_content_fh_from_closure {
    my ($self) = @_;
    return $self->content_fh_from_closure->();
}

1;

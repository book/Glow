package Glow::Actor;

use Moose;
use namespace::autoclean;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);
has email => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

# private attributes
has ident => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
    init_arg   => undef,
);

sub _build_ident { $_[0]->name . ' <' . $_[0]->email . '>' }

__PACKAGE__->meta->make_immutable;

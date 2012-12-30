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

# ABSTRACT: An actor in Glow

=head1 SYNOPSIS

    use Glow::Actor;

    my $actor = Glow::Actor->new(
        name  => 'Philippe Bruhat (BooK)',
        email => 'book@cpan.org'
    );

    print $actor->ident;    # Philippe Bruhat (BooK) <book@cpan.org>

=head1 DESCRIPTION

L<Glow::Actor> represents a user in L<Glow>, i.e. the combination of a
name and an email.

=attr name

The name of the L<Glow::Actor>.

=attr email

The email of the L<Glow::Actor>.

=attr ident

The identity of the L<Glow::Actor>, build as:

    Name <email>

=cut

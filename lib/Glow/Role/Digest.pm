package Glow::Role::Digest;
use MooseX::Role::Parameterized;

use Digest;

requires qw( kind size content content_fh );

parameter algorithm => (
    isa      => 'Str',
    required => 1,
);

role {
    my $param     = shift;
    my $algorithm = $param->algorithm;

    has digest => (
        is       => 'ro',
        isa      => 'Str',
        lazy     => 1,
        required => 0,
        builder  => '_build_digest',
    );

    method _build_digest => sub {
        my ($self) = @_;
        my $digest = Digest->new($algorithm);
        $digest->add( $self->kind . ' ' . $self->size . "\0" );
        if ( $self->has_content ) {
            $digest->add( $self->content );
        }
        else {
            $digest->addfile( $self->content_fh );
        }
        return $digest->hexdigest;
    };
};

1;

# ABSTRACT: Parametric role that adds a digest attribute to a Glow object

=pod

=head1 SYNOPSIS

    # write a Git blob object class
    package Glow::Repository::Git::Object::Blob;

    use Moose;

    with 'Glow::Role::Blob',
        'Glow::Role::Digest' => { algorithm => 'SHA-1' },
        'Glow::Role::ContentBuilder::FromGit';

    sub kind {'blob'}

    1;

    # or program it
    Moose::Meta::Class->create(
        'Glow::Repository::Git::Object::Blob',
        superclasses => ['Moose::Object'],
        roles        => [
            'Glow::Role::Blob',
            'Glow::Role::Digest' => { algorithm => 'SHA-1', },
            'Glow::Role::ContentBuilder::FromGit',
        ],
        methods => { kind => sub {'blob'}, },
    );

=head1 DESCRIPTION

L<Glow::Role::Digest> adds a I<digest> attribute to a L<Glow::Object>.

=head1 ROLE PARAMETERS

This role has a single, required, parameter.

=head2 algorithm

The I<algorithm> parameter allows you to select the actual digest
algorithm. Any value that the L<Digest> module recognize is valid
(as L<Digest> is used in the backend).

=attr digest

The digest of the object's content.

If actually computes the digest of the content, prepended by
the object I<kind>, a single space character, the ASCII decimal
representation of the content size, and a NULL byte.

For example, if the object is a C<blob> and the content is C<hello>,
the digest value is computed on the string C<blob 5\0hello>.

=cut

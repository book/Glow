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

    __PACKAGE__->meta->make_immutable;

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

    Glow::Repository::Git::Object::Blob->meta->make_immutable;

=head1 DESCRIPTION

L<Glow::Role::Digest> adds a I<digest> attribute to a L<Glow> object.

=attr digest

The digest of the object content.

If actually computes the digest of the content, prepended by
the object I<kind>, a single space character, the ASCII decimal
representation of the content size, and a NULL byte.

For example, if the object is a C<blob> and the content is C<hello>,
the digest value is computed from the string C<blob 5\0hello>.

=head1 ROLE PARAMETERS

This role has a single, required, parameter.

=head2 algorithm

The I<algorithm> parameter allows you to select the actual digest
algorithm. Any value that the L<Digest> module recognize is valid
(as L<Digest> is used in the backend).

=head1 REQUIRED METHODS

This role is usually consumed along with L<Glow::Role::Object>,
which also provides most of the required methods described below
(C<kind> being the notable exception).

=head2 kind

The object kind.

=head2 size

The object size in bytes.

=head2 content

The object content.

=head2 content_fh

A filehandle from which the content can be read.

=cut

package Glow::Role::Object;
use Moose::Role;

use FileHandle  ();
use IO::String  ();
use Fcntl qw( SEEK_END );

requires 'kind';

with 'Glow::Role::ContentBuilder::FromFile';
with 'Glow::Role::ContentBuilder::FromClosure';

# all attributes are read-only

# these attributes can be generated, and need not to be set in the constructor
sub size;
has size => (
    is       => 'ro',
    isa      => 'Int',
    lazy     => 1,
    required => 0,
    builder  => '_build_size',
);

sub content;
has content => (
    is        => 'ro',
    isa       => 'Str',
    lazy      => 1,
    required  => 0,
    builder   => '_build_content',
    predicate => 'has_content',
);

# set by the Glow::Role::ContentBuilder:: roles using _content_from_trigger
has content_builder => (
    is       => 'ro',
    isa      => 'Str',
    required => 0,
    writer   => '_set_content_builder',
    init_arg => undef,
);

sub as_string { $_[0]->content }

# everywhere, try as hard as we can to avoid actually building content
# but use it if it's available

# builders
sub _build_content {
    my ($self) = @_;
    my $fh = $self->content_fh;
    local $/;
    return <$fh> // '';
};

sub _build_size {
    my ($self) = @_;
    return length $self->content if $self->has_content;

    my $fh = $self->content_fh;
    if( $fh->can('seek') ) {
        $fh->seek( 0, SEEK_END );
        return $fh->tell;
    }
    else {
        my $size = 0;
        my $buffer;
        while ( my $read = $fh->sysread( $buffer, 8192 ) ) { $size += $read }
        return $size;
    }
}

sub content_fh {
    my ($self) = @_;
    my $method = $self->content_builder
        && '_build_fh_using_' . $self->content_builder;
    return
          $self->has_content ? IO::String->new( $self->content )
        : $method            ? $self->$method
        :                      IO::String->new('');
}

# private method
sub _content_from_trigger {
    my ( $self, $attribute ) = @_;
    my $error
        = $self->has_content
        ? "Can't provide content with $attribute (content already provided)"
        : $self->content_builder
        ? "Can't set content_builder to $attribute (already set to ${\$self->content_builder})"
        : '';
    die $error if $error;
    $self->_set_content_builder($attribute);
}

1;

# ABSTRACT: The core of what a Glow object does

=pod

=head1 SYNOPSIS

    # write a custom object class
    package My::Glow::Object;

    use Moose;

    with 'Glow::Role::Object',
        'Glow::Role::Digest' => { algorithm => 'SHA-256' };

    sub kind {'my-object'}

    has some_attribute => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    1;

=head1 DESCRIPTION

=attr content

The object's actual content.

=attr size

The size (in bytes) of the object content.

=meth kind

Returns the object "kind". This method must be defined in the class
consuming this role.

As an example, in Git, it's one of C<blob>, C<tree>, C<commit>, and C<tag>.

=meth content_fh

Returns a newly opened filehandle on the object content.

This method is recommended over using C<content> directly,
as it makes it possible to process objects of arbitrary size.
(The actual filehandle creation is usually delegated to one
of the composed L<Glow::Role::ContentBuilder> roles.)

By default, L<Glow::Role::Object> composes
the L<Glow::Role::ContentBuilder::FromFile>
and L<Glow::Role::ContentBuilder::FromClosure>
roles.

=meth as_string

Return a string representation of the content.

By default, same as C<content()>, but some classes may override it.

=cut

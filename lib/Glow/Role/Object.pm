package Glow::Role::Object;
use Moose::Role;

use Carp;
use Digest::SHA ();
use FileHandle  ();
use IO::String  ();
use Fcntl qw( SEEK_END );

requires 'kind';

# all attributes are read-only

# these attributes can be generated, and need not to be set in the constructor
has size => (
    is       => 'ro',
    isa      => 'Int',
    lazy     => 1,
    required => 0,
    builder  => '_build_size',
);

has sha1 => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    builder  => '_build_sha1',
);

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
);

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
    $fh->seek( 0, SEEK_END );
    return $fh->tell;
}

sub _build_sha1 {
    my ($self) = @_;
    my $sha1 = Digest::SHA->new(1);
    $sha1->add( $self->kind . ' ' . $self->size . "\0" );
    if ( $self->has_content ) {
        $sha1->add( $self->content );
    }
    else {
        $sha1->addfile( $self->content_fh );
    }
    return $sha1->hexdigest;
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

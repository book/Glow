package Glow::Object;
use Moose::Role;

use FileHandle;
use IO::String;
use Fcntl qw( SEEK_END );
use Digest::SHA1;

# all attributes are read-only

has kind => ( is => 'ro', isa => 'Str', lazy_build => 1, init_arg => undef );

# these attributes can be generated, and need not to be set in the constructor
has size => ( is => 'ro', isa => 'Int', lazy_build => 1, required => 0 );
has sha1 => ( is => 'ro', isa => 'Str', lazy_build => 1, required => 0 );
has content => ( is => 'ro', isa => 'Str', lazy_build => 1, required => 0 );

# a coderef that will always return a filehandle pointing at the beginning of the content
has content_source => ( is => 'ro', isa => 'CodeRef', required => 0, predicate => 'has_content_source' );

# builders
sub _build_kind {
    my ($self) = @_;
    my $class = ref $self;
    $class =~ /^Glow::Object::(\w+)$/;
    return lc $1;
}

sub _build_size {
    my ($self) = @_;

    return length $self->content if $self->has_content;

    my $fh = $self->content_fh;
    $fh->seek( 0, SEEK_END );
    return $fh->tell;
}

sub _build_sha1 {
    my ($self) = @_;
    my $sha1 = Digest::SHA1->new;
    $sha1->add( $self->kind . ' ' . $self->size . "\0" );
    if ( $self->has_content ) {
        $sha1->add( $self->content );
    }
    else {
        $sha1->addfile( $self->content_fh );
    }
    return $sha1->hexdigest;
}

sub _build_content {
    my ($self) = @_;
    my $fh = $self->content_fh;
    local $/;
    return <$fh>;
}

# methods
sub content_fh {
    my ($self) = @_;
    return $self->has_content
        ? IO::String->new( $self->content )
        : $self->content_source->();
}

1;

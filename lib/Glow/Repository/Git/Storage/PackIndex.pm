package Glow::Repository::Git::Storage::PackIndex;

use Moose;
use MooseX::Types::Path::Class;
use IO::File;
use namespace::autoclean;

has 'filename' => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 1,
    coerce   => 1
);

has 'fh' => (
    is       => 'ro',
    isa      => 'IO::File',
    required => 0,
    lazy     => 1,
    builder  => '_build_fh',
);

has 'offsets' => (
    is         => 'ro',
    isa        => 'ArrayRef[Int]',
    required   => 0,
    lazy       => 1,
    builder    => '_build_offsets',
    auto_deref => 1,
);

has 'size' => (
    is       => 'ro',
    isa      => 'Int',
    required => 0,
    lazy     => 1,
    builder  => '_build_size',
);

my $FanOutCount   = 256;
my $IdxOffsetSize = 4;

sub _build_fh {
    my ($self) = @_;
    my $filename = $self->filename;
    return IO::File->new($filename)
        or die "Can't open $filename: $!";
}

sub _build_offsets {
    my ($self) = @_;
    my @offsets = (0);

    my $fh = $self->fh;
    $fh->seek( $self->global_offset, 0 );
    foreach my $i ( 0 .. $FanOutCount - 1 ) {
        $fh->read( my $data, $IdxOffsetSize );
        my $offset = unpack( 'N', $data );
        die "pack has discontinuous index" if $offset < $offsets[-1];
        push @offsets, $offset;
    }
    return \@offsets;
}

sub _build_size { ( $_[0]->offsets )[-1]; }

__PACKAGE__->meta->make_immutable;

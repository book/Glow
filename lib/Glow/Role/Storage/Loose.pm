package Glow::Role::Storage::Loose;
use MooseX::Role::Parameterized;
use MooseX::Types::Path::Class;

use Path::Class::File ();
use IO::Uncompress::Inflate qw( $InflateError) ;
use IO::Compress::Deflate qw( $DeflateError) ;
use Digest;

with 'Glow::Role::Storage';

has 'directory' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    required => 1,
    coerce   => 1,
);

parameter algorithm => (
    isa      => 'Str',
    required => 1,
);

role {
    my $param = shift;
    my $segments
        = int( length( Digest->new( $param->algorithm )->hexdigest ) / 32 );

    # some reasonable way to split the digest in segments
    method digest_segments => sub {
        my ( $self, $digest ) = @_;
        return map( { substr $digest, 2 * $_, 2 } 0 .. $segments - 1 ),
            substr $digest, 2 * $segments;
    };
};

sub _build_readonly { '' }

sub _object_filename {
    my ( $self, $digest ) = @_;
    return Path::Class::File->new( $self->directory,
        $self->digest_segments($digest) );
}

sub has_object {
    my ( $self, $digest ) = @_;
    return !! -f $self->_object_filename($digest);
}

sub get_object {
    my ( $self, $digest ) = @_;

    my $filename = $self->_object_filename($digest);
    return if !-f $filename;

    # create a filehandle to read from
    my $zh = IO::Uncompress::Inflate->new("$filename")
        or die "Can't open $filename: $InflateError";

    # get the kind and size information
    my $header = do { local $/ = "\0"; $zh->getline; };
    my ( $kind, $size ) = $header =~ /^(\w+) (\d+)\0/;

    # closure that returns a filehandle
    # pointing at the beginning of the content
    my $build_fh = sub {
        my $zh = IO::Uncompress::Inflate->new("$filename")
            or die "Can't open $filename: $InflateError";
        do { local $/ = "\0"; $zh->getline; };
        return $zh;
    };

    # pick up the class that will instantiate the object
    return $self->kind2class($kind)->new(
        size                    => $size,
        digest                  => $digest,
        content_fh_from_closure => $build_fh,
    );
}

sub put_object {
    my ( $self, $object ) = @_;

    # the simple cases
    return 1  if $self->has_object( $object->digest );
    return '' if $self->readonly;

    # target filename
    my $filename = $self->_object_filename( $object->digest );
    $filename->parent->mkpath;

    # filehandle to read from
    my $fh = $object->content_fh;

    # save to compressed temporary file
    my ( undef, $tempfile ) = $filename->parent->tempfile;
    my $zh = IO::Compress::Deflate->new( $tempfile )
        or die "Can't open $filename: $DeflateError";
    my $buffer = $object->kind . ' ' . $object->size . "\0";
    while ( length $buffer ) {
        $zh->syswrite($buffer)
            or die "Error writing to $filename: $!";
        my $read = $fh->sysread( $buffer, 8192 );
        die "Error reading content from ${\$object->digest}: $!"
            if !defined $read;
    }

    # move it to its final destination
    rename $tempfile, $filename;
}

sub delete_object {
    my ( $self, $digest ) = @_;
    return 0 if $self->readonly;
    return unlink $self->_object_filename( $digest );
}

1;


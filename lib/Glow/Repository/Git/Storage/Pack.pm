package Glow::Repository::Git::Storage::Pack;

use Moose;
use MooseX::Types::Path::Class;
use IO::File;
use namespace::autoclean;

with 'Glow::Repository::Git::Storage';

has filename => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 1,
    coerce   => 1,
);

has index_filename => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 0,
    coerce   => 1,
    lazy     => 1,
    builder  => '_build_index_filename',
);

has index => (
    is       => 'ro',
    isa      => 'Glow::Repository::Git::Storage::PackIndex',
    required => 0,
    lazy     => 1,
    builder  => '_build_index',
);

has 'fh' => (
    is       => 'ro',
    isa      => 'IO::File',
    required => 0,
    lazy     => 1,
    builder  => '_build_fh',
);

# packs are readonly
sub _build_readonly {1}

sub _build_index_filename {
    my ($self) = @_;
    my $index_filename = $self->filename;
    $index_filename =~ s/\.pack$/.idx/;
    return $index_filename;
}

sub _build_index {
    my ($self) = @_;
    my $index_filename = $self->index_filename;

    # create the index if the file does not exist
    $self->create_index if !-e $index_filename;

    # read the magic number
    my $index_fh = IO::File->new($index_filename)
        or die "Can't open $index_filename: $!";
    $index_fh->binmode();
    $index_fh->read( my $signature, 4 );
    $index_fh->read( my $version,   4 );
    $version = unpack( 'N', $version );
    $index_fh->close;

    # find out the index class
    $version = $signature eq "\377tOc" ? $version : '1';
    my $class = "Glow::Repository::Git::Storage::PackIndex::Version$version";
    eval "require $class" or die $@;

    return $class->new( filename => $index_filename );
}

sub _build_fh {
    my ($self) = @_;
    my $filename = $self->filename;
    my $fh = IO::File->new($filename) or die "Can't open $filename: $!";
    $fh->binmode();
    return $fh;
}

# Glow::Role::Storage methods
sub has_object {
    my ( $self, $digest ) = @_;
    return !!$self->index->get_object_offset($digest);
}

sub get_object {
    my ( $self, $digest ) = @_;
    my $offset = $self->index->get_object_offset($digest);
    return unless $offset;

    my ( $kind, $size, $content ) = $self->unpack_object($offset);
    return $self->kind2class($kind)->new(
        digest  => $digest,
        size    => $size,
        content => $content
    );
}

# packs are read-only
sub put_object {''}

sub delete_object {0}

# this code comes quasi-verbatim from Git::PurePerl::Pack::WithoutIndex
my @TYPES = ( 'none', 'commit', 'tree', 'blob', 'tag', '', 'ofs_delta',
    'ref_delta' );
my $OBJ_NONE      = 0;
my $OBJ_COMMIT    = 1;
my $OBJ_TREE      = 2;
my $OBJ_BLOB      = 3;
my $OBJ_TAG       = 4;
my $OBJ_OFS_DELTA = 6;
my $OBJ_REF_DELTA = 7;

my $SHA1Size = 20;

sub create_index {
    my ($self) = @_;
    my $index_filename = $self->index_filename;
    my $index_fh = IO::File->new( $index_filename, '>' )
        or die "Can't open $index_filename: $!";

    my $digest = Digest->new('SHA-1');

    my $offsets = $self->_create_index_offsets;
    my @fan_out_table;
    foreach my $sha1 ( sort keys %$offsets ) {
        my $offset = $offsets->{$sha1};
        my $slot = unpack( 'C', pack( 'H*', $sha1 ) );
        $fan_out_table[$slot]++;
    }

    my $print = sub {
        $index_fh->print( $_[0] ) or die "$!";
        $digest->add( $_[0] );
    };
    foreach my $i ( 0 .. 255 ) {
        $print->( pack( 'N', $fan_out_table[$i] || 0 ) );
        $fan_out_table[ $i + 1 ] += $fan_out_table[$i] || 0;
    }
    foreach my $sha1 ( sort keys %$offsets ) {
        my $offset = $offsets->{$sha1};
        $print->( pack( 'N',  $offset ) );
        $print->( pack( 'H*', $sha1 ) );
    }

    # read the pack checksum from the end of the pack file
    my $size = -s $self->filename;
    my $fh   = $self->fh;
    $fh->seek( $size - 20, 0 ) || die $!;
    my $read = $fh->read( my $pack_sha1, 20 ) || die $!;

    $index_fh->print($pack_sha1) || die $!;
    $index_fh->print( $digest->digest ) || die $!;

    $index_fh->close() || die $!;
}

sub _create_index_offsets {
    my ($self) = @_;
    my $fh = $self->fh;

    $fh->seek( 0, 0 );    # a bit defensive (file was just opened)
    $fh->read( my $signature, 4 );
    $fh->read( my $version,   4 );
    $version = unpack( 'N', $version );
    $fh->read( my $objects, 4 );
    $objects = unpack( 'N', $objects );

    my %offsets;
    foreach my $i ( 1 .. $objects ) {
        my $offset = $fh->tell || die "Error telling filehandle: $!";
        my $obj_offset = $offset;
        $fh->read( my $c, 1 ) || die "Error reading from pack: $!";
        $c = unpack( 'C', $c ) || die $!;
        $offset++;

        my $size        = ( $c & 0xf );
        my $type_number = ( $c >> 4 ) & 7;
        my $type        = $TYPES[$type_number]
            || confess
            "invalid type $type_number at offset $offset, size $size";

        my $shift = 4;

        while ( ( $c & 0x80 ) != 0 ) {
            $fh->read( $c, 1 ) || die $!;
            $c = unpack( 'C', $c ) || die $!;
            $offset++;
            $size |= ( ( $c & 0x7f ) << $shift );
            $shift += 7;
        }

        my $content;

        if ( $type eq 'ofs_delta' || $type eq 'ref_delta' ) {
            ( $type, $size, $content )
                = $self->unpack_deltified( $type, $offset, $obj_offset, $size,
                \%offsets );
        }
        elsif ($type eq 'commit'
            || $type eq 'tree'
            || $type eq 'blob'
            || $type eq 'tag' )
        {
            $content = $self->read_compressed( $offset, $size );
        }
        else {
            confess "invalid type $type";
        }

        my $raw  = $type . ' ' . $size . "\0" . $content;
        my $sha1 = Digest::SHA->new;
        $sha1->add($raw);
        my $sha1_hex = $sha1->hexdigest;
        $offsets{$sha1_hex} = $obj_offset;
    }

    return \%offsets;
}

# actual pack-reading methods
# this code comes quasi-verbatim from Git::PurePerl::Pack
sub unpack_object {
    my ( $self, $offset ) = @_;
    my $obj_offset = $offset;
    my $fh         = $self->fh;

    $fh->seek( $offset, 0 ) || die "Error seeking in pack: $!";
    $fh->read( my $c, 1 ) || die "Error reading from pack: $!";
    $c = unpack( 'C', $c ) || die $!;

    my $size        = ( $c & 0xf );
    my $type_number = ( $c >> 4 ) & 7;
    my $type = $TYPES[$type_number] || confess "invalid type $type_number";

    my $shift = 4;
    $offset++;

    while ( ( $c & 0x80 ) != 0 ) {
        $fh->read( $c, 1 ) || die $!;
        $c = unpack( 'C', $c ) || die $!;
        $size |= ( ( $c & 0x7f ) << $shift );
        $shift  += 7;
        $offset += 1;
    }

    if ( $type eq 'ofs_delta' || $type eq 'ref_delta' ) {
        ( $type, $size, my $content )
            = $self->unpack_deltified( $type, $offset, $obj_offset, $size );
        return ( $type, $size, $content );

    }
    elsif ($type eq 'commit'
        || $type eq 'tree'
        || $type eq 'blob'
        || $type eq 'tag' )
    {
        my $content = $self->read_compressed( $offset, $size );
        return ( $type, $size, $content );
    }
    else {
        confess "invalid type $type";
    }
}

sub read_compressed {
    my ( $self, $offset, $size ) = @_;
    my $fh = $self->fh;

    $fh->seek( $offset, 0 ) || die $!;
    my ( $deflate, $status ) = Compress::Raw::Zlib::Inflate->new(
        -AppendOutput => 1,
        -ConsumeInput => 0
    );

    my $out = "";
    while ( length($out) < $size ) {
        $fh->read( my $block, 4096 ) || die $!;
        my $status = $deflate->inflate( $block, $out );
    }
    confess length($out) . " is not $size" unless length($out) == $size;

    $fh->seek( $offset + $deflate->total_in, 0 ) || die $!;
    return $out;
}

sub unpack_deltified {
    my ( $self, $type, $offset, $obj_offset, $size ) = @_;
    my $fh = $self->fh;

    my $base;

    $fh->seek( $offset, 0 ) || die $!;
    $fh->read( my $data, $SHA1Size ) || die $!;
    my $sha1 = unpack( 'H*', $data );

    if ( $type eq 'ofs_delta' ) {
        my $i           = 0;
        my $c           = unpack( 'C', substr( $data, $i, 1 ) );
        my $base_offset = $c & 0x7f;

        while ( ( $c & 0x80 ) != 0 ) {
            $c = unpack( 'C', substr( $data, ++$i, 1 ) );
            $base_offset++;
            $base_offset <<= 7;
            $base_offset |= $c & 0x7f;
        }
        $base_offset = $obj_offset - $base_offset;
        $offset += $i + 1;

        ( $type, undef, $base ) = $self->unpack_object($base_offset);
    }
    else {
        ( $type, undef, $base ) = $self->get_object($sha1);
        $offset += $SHA1Size;

    }

    my $delta = $self->read_compressed( $offset, $size );
    my $new = $self->patch_delta( $base, $delta );

    return ( $type, length($new), $new );
}

sub patch_delta {
    my ( $self, $base, $delta ) = @_;

    my ( $src_size, $pos ) = $self->patch_delta_header_size( $delta, 0 );
    if ( $src_size != length($base) ) {
        confess "invalid delta data";
    }

    ( my $dest_size, $pos ) = $self->patch_delta_header_size( $delta, $pos );
    my $dest = "";

    while ( $pos < length($delta) ) {
        my $c = substr( $delta, $pos, 1 );
        $c = unpack( 'C', $c );
        $pos++;
        if ( ( $c & 0x80 ) != 0 ) {

            my $cp_off  = 0;
            my $cp_size = 0;
            $cp_off = unpack( 'C', substr( $delta, $pos++, 1 ) )
                if ( $c & 0x01 ) != 0;
            $cp_off |= unpack( 'C', substr( $delta, $pos++, 1 ) ) << 8
                if ( $c & 0x02 ) != 0;
            $cp_off |= unpack( 'C', substr( $delta, $pos++, 1 ) ) << 16
                if ( $c & 0x04 ) != 0;
            $cp_off |= unpack( 'C', substr( $delta, $pos++, 1 ) ) << 24
                if ( $c & 0x08 ) != 0;
            $cp_size = unpack( 'C', substr( $delta, $pos++, 1 ) )
                if ( $c & 0x10 ) != 0;
            $cp_size |= unpack( 'C', substr( $delta, $pos++, 1 ) ) << 8
                if ( $c & 0x20 ) != 0;
            $cp_size |= unpack( 'C', substr( $delta, $pos++, 1 ) ) << 16
                if ( $c & 0x40 ) != 0;
            $cp_size = 0x10000 if $cp_size == 0;

            $dest .= substr( $base, $cp_off, $cp_size );
        }
        elsif ( $c != 0 ) {
            $dest .= substr( $delta, $pos, $c );
            $pos += $c;
        }
        else {
            confess 'invalid delta data';
        }
    }

    if ( length($dest) != $dest_size ) {
        confess 'invalid delta data';
    }
    return $dest;
}

sub patch_delta_header_size {
    my ( $self, $delta, $pos ) = @_;

    my $size  = 0;
    my $shift = 0;
    while (1) {

        my $c = substr( $delta, $pos, 1 );
        unless ( defined $c ) {
            confess 'invalid delta header';
        }
        $c = unpack( 'C', $c );

        $pos++;
        $size |= ( $c & 0x7f ) << $shift;
        $shift += 7;
        last if ( $c & 0x80 ) == 0;
    }
    return ( $size, $pos );
}

__PACKAGE__->meta->make_immutable;

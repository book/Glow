package Glow::Role::HashFromContent;

use Moose::Role;

requires qw( _header_spec _build_fh_using_attributes );

use Encode qw( decode );

has hash => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 0,
    lazy     => 1,
    builder  => '_build_hash',
    init_arg => undef,
);

sub _build_hash {
    my ($self) = @_;
    my %spec   = $self->_header_spec;
    my $hash   = {};

    # build the key-value pairs
    my %header;
    my @lines = split "\n", $self->content;
    while ( my $line = shift @lines ) {
        my ( $key, $value ) = split / /, $line, 2;
        push @{ $header{$key} }, $value;
        $header{''} = $header{$key} if $key;    # deal with continuation lines
    }
    delete $header{''};

    # deal with encoding (if any)
    my $encoding = exists $spec{encoding} && ( $header{encoding} || 'utf-8' );

    # process each pair
    for my $key ( keys %header ) {
        my ( $attr, $type ) = @{ $spec{$key} || [ $key, '-' ] };
        $header{$key} = [ map decode( $encoding, $_ ), @{ $header{$key} } ]
            if $encoding;
        $hash->{$attr}
            = $type eq '-' ? $header{$key}[-1]
            : $type eq '@' ? $header{$key}
            : $type eq '=' ? join( "\n", @{ $header{$key} } ) . "\n"
            :   die "Unknown type $type in $attr handler for $key";
    }

    # whatever's left is the content body
    $hash->{body} = join "\n", @lines;

    return $hash;
}

1;

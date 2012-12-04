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

package Glow::Role::Repository;
use Moose::Role;
use MooseX::Types::Path::Class;

use Glow::Config;
use Glow::Store;

requires qw( _build_object_store );

has 'directory' => (
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    required => 1,
    coerce   => 1,
);

has 'config' => (
    is       => 'ro',
    isa      => 'Glow::Config',
    required => 0,
    lazy     => 1,
    builder  => '_build_config',
);

has 'object_store' => (
    is         => 'ro',
    isa        => 'Glow::Store',
    required   => 0,
    lazy       => 1,
    builder    => '_build_object_store',
    handles    => [ 'get_object', 'put_object' ],
);

sub _build_config {
    my ($self) = @_;
    return Glow::Config->new( repository => $self );
}

1;

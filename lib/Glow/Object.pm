package Glow::Object;
use Moose::Role;

use Digest::SHA1;

has kind => ( is => 'ro', isa => 'Str', lazy_build => 1, init_arg => undef );
has size => ( is => 'ro', isa => 'Int', lazy_build => 1, required => 0 );
has sha1 => ( is => 'ro', isa => 'Str', lazy_build => 1, required => 0 );
has content => ( is => 'ro', isa => 'Str', lazy_build => 1, required => 0 );

1;

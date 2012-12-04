package Glow::Role::DirectoryEntry;
use Moose::Role;

has 'mode'     => ( is => 'ro', isa => 'Str', required => 1 );
has 'filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'digest'   => ( is => 'ro', isa => 'Str', required => 1 );

sub as_content {
    my ($self) = @_;
    return
          $self->mode . ' '
        . $self->filename . "\0"
        . pack( 'H*', $self->digest );
}

1;


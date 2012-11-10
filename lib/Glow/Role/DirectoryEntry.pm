package Glow::Role::DirectoryEntry;
use Moose::Role;

has 'mode'     => ( is => 'ro', isa => 'Str', required => 1 );
has 'filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'sha1'     => ( is => 'ro', isa => 'Str', required => 1 );

sub as_content {
    my ($self) = @_;
    return
          $self->mode . ' '
        . $self->filename . "\0"
        . pack( 'H*', $self->sha1 );
}

1;


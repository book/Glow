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

sub as_string {
    my ($self) = @_;
    my $mode = oct( '0' . $_->mode );
    return sprintf "%06o %s %s\t%s\n", $mode,
        $mode & 0100000 ? 'blob' : 'tree',
        $self->digest, $self->filename;
}

1;


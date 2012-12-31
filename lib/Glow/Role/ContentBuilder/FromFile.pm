package Glow::Role::ContentBuilder::FromFile;
use Moose::Role;

requires '_content_from_trigger';

has content_from_file => (
    is       => 'ro',
    isa      => 'Str',
    required => 0,
    trigger  => sub { $_[0]->_content_from_trigger('content_from_file'); },
);

sub _build_fh_using_content_from_file {
    my ($self) = @_;
    my $source = $self->content_from_file;
    open my $fh, '<', $source or die "Can't open $source: $!";
    return $fh;
}

1;

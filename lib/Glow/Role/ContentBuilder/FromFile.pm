package Glow::Role::ContentBuilder::FromFile;
use Moose::Role;

with 'Glow::Role::ContentBuilder';

has content_from_file => (
    is       => 'ro',
    isa      => 'Str',
    required => 0,
    trigger  => sub { $_[0]->_trigger('content_from_file'); },
);

sub _build_fh_using_content_from_file {
    my ($self) = @_;
    my $source = $self->content_from_file;
    die "$source does not exist" if !-e $source;
    die "$source is unreadable"  if !-r $source;
    open my $fh, '<', $source or die "Can't open $source: $!";
    return $fh;
}

1;

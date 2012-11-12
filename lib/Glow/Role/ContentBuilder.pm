package Glow::Role::ContentBuilder;
use Moose::Role;

sub _trigger {
    my ( $self, $attribute ) = @_;
    my $method = "_build_fh_using_$attribute";
    my $error
        = $self->has_content
        ? "Can't provide content with $attribute (content already provided)"
        : $self->content_builder
        ? "Can't set content_builder to $method (already set to ${\$self->content_builder})"
        : '';
    die $error if $error;
    $self->_set_content_builder($method);
}

1;


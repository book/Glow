package Glow::Role::ContentBuilder;
use Moose::Role;

sub _trigger {
    my ( $self, $attribute ) = @_;
    my $error
        = $self->has_content
        ? "Can't provide content with $attribute (content already provided)"
        : $self->content_builder
        ? "Can't set content_builder to $attribute (already set to ${\$self->content_builder})"
        : '';
    die $error if $error;
    $self->_set_content_builder($attribute);
}

1;


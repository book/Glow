package Glow::Repository;

use Moose;

with 'Glow::Role::Repository';

around new => sub {
    my ( $orig, $class, @args ) = @_;
    my $self = $class->$orig(@args);

    # get the class from the config
    $class = $self->config->get( key => 'glow.class' )
        || 'Glow::Repository::Git';
    eval "require $class";
    $class->new(@args);
};

sub _build_objects_stores;    # stub

1;

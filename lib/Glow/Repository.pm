package Glow::Repository;

use Moose;
use namespace::autoclean;

with 'Glow::Role::Repository';

sub _build_object_store;    # stub

sub spawn {
  my $self = shift;
  $self->config->get( key => 'glow.class' )
        || 'Glow::Repository::Git';
    eval "require $class" or die $@;
  $class->new(@_);
}


__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

# ABSTRACT: Factory class to build objects doing Glow::Role::Repository

=pod

=head1 SYNOPSIS

    use Glow::Repository;

    # .git is a Git repository's GIT_DIR
    my $r = Glow::Repository->new( directory => '.git' );

    # $r is now a Glow::Repository::Git object

=head1 DESCRIPTION

L<Glow::Repository> is a factory class that will instanciate the proper
repository class based on the repository configuration.

By default, a L<Glow> repository contain a single file named F<config>
that holds at least this configuration (readable by L<Glow::Config>):

    [glow]
    	class = Class::Doing::Glow::Role::Repository

By default (see the L</SYNOPSIS>), if the C<[glow]> configuration section
does not exist in the F<config> file, it is assumed the repository is a
Git repository, and the class defaults to L<Glow::Repository::Git>.

=cut

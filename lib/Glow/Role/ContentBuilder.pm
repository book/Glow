package Glow::Role::ContentBuilder;

use Moose::Role;

requires '_content_from_trigger';

1;

# ABSTRACT: base role for content-builder roles

=head1 SYNOPSIS

    package Glow::Role::ContentBuilder::FromSomeAttribute;
    use Moose::Role;

    with 'Glow::Role::ContentBuilder';

    has some_attribute => (
        is       => 'ro',
        isa      => 'Str',
        required => 0,
        trigger  => sub { $_[0]->_content_from_trigger('some_attribute'); },
    );

    sub _build_fh_using_some_attribute {
        my ($self) = @_;

        # build a filehandle using $self->some_attribute;
        my $fh = ...;

        return $fh;
    }

    1;

=head1 DESCRIPTION

The roles that specialize L<Glow::Role::ContentBuilder> define new ways
to get the content for an object (apart from passing it directly).

This is done by defining a new attribute and a specific method (named
after the attribute) that will act as a builder for a filehandle that
returns the actual content data.

The L<Glow::Role::Object> role defines a C<_content_from_trigger()>
method, to be used in the attribute trigger. That method ensures that
only one of the content-providing attributes is set in the constructor.

L<Glow::Role::Object> uses the C<_build_fh_using_I<attribute>> method
in its C<content_fh()> method, to provide a filehandle from which to
read the content built from the attribute.

=head1 SEE ALSO

L<Glow> has a number of content-building roles, that are used to build
some of its object kinds from diverse sources (files, subroutines,
data structures or external programs):
L<Glow::Role::ContentBuilder::FromClosure>,
L<Glow::Role::ContentBuilder::FromCommitInfo>,
L<Glow::Role::ContentBuilder::FromDirectoryEntries>,
L<Glow::Role::ContentBuilder::FromFile>,
L<Glow::Role::ContentBuilder::FromGit>,
L<Glow::Role::ContentBuilder::FromTagInfo>.

=cut

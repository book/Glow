package Glow::Repository::Git::Tag;

use Moose;

with 'Glow::Role::Object',
    'Glow::Role::Digest' => { algorithm => 'SHA-1' },
    'Glow::Role::HashFromContent',
    'Glow::Role::ContentBuilder::FromGit';

use DateTime::TimeZone;
use IO::String;

sub kind {'tag'}

*sha1 = \&digest;

sub _header_spec { () }    # nothing special

has object => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->hash->{object} },
);

has type => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->hash->{type} },
);

has tag => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->hash->{tag} },
);

has tagger => (
    is       => 'ro',
    isa      => 'Glow::Actor',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->_build_actor_attr('tagger') },
);

has tagged_time => (
    is       => 'ro',
    isa      => 'DateTime',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->_build_actor_attr( 'tagger', 'tagged_time' ) },
);

has comment => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->hash->{body} },
);

sub tag_info {
    my ($self) = @_;
    return {
        map( ( $_ => $self->$_ ),
            qw( object type tag tagger tagged_time comment ) ),
    };
}

sub _build_fh_using_attributes {
    my ($self) = @_;

    my $content;
    $content .= "$_ " . $self->$_ . "\n" for qw( object type tag );
    $content .= join(
        ' ',
        tagger => $self->tagger->ident,
        $self->tagged_time->epoch,
        DateTime::TimeZone->offset_as_string( $self->tagged_time->offset )
    ) . "\n";
    $content .= "\n";
    my $comment = $self->comment;
    chomp $comment;
    $content .= "$comment\n";

    return IO::String->new($content);
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

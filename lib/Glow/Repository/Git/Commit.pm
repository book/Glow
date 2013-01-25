package Glow::Repository::Git::Commit;

use Moose;

with 'Glow::Role::Object',
    'Glow::Role::Digest' => { algorithm => 'SHA-1' },
    'Glow::Role::HashFromContent',
    'Glow::Role::ContentBuilder::FromGit';

use DateTime::TimeZone;
use IO::String;

sub kind {'commit'}

*sha1 = \&digest;

sub _header_spec {
    return (    # only list the headers that are special
        tree     => [ tree_digest    => '-' ],
        parent   => [ parents_digest => '@' ],
        encoding => [ encoding       => '-' ],    # encoding *must* be listed
    );
}

has tree_digest => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->hash->{tree_digest}; },
);

has parents_digest => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    lazy       => 1,
    required   => 0,
    auto_deref => 1,
    default    => sub { $_[0]->hash->{parents_digest} || [] },
    predicate  => 'has_parents_digest',
);

has author => (
    is       => 'ro',
    isa      => 'Glow::Actor',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->_build_actor_attr('author'); },
);

has authored_time => (
    is       => 'ro',
    isa      => 'DateTime',
    lazy     => 1,
    required => 0,
    default => sub { $_[0]->_build_actor_attr( 'author', 'authored_time' ); },
);

has committer => (
    is       => 'ro',
    isa      => 'Glow::Actor',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->_build_actor_attr('committer'); },
);

has committed_time => (
    is       => 'ro',
    isa      => 'DateTime',
    lazy     => 1,
    required => 0,
    default =>
        sub { $_[0]->_build_actor_attr( 'committer', 'committed_time' ) },
);

has comment => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->hash->{body} },
);

has encoding => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    required => 0,
    default  => sub { $_[0]->hash->{encoding} || 'utf-8' },
);

sub commit_info {
    my ($self) = @_;
    return {
        parents_digest => [ $self->parents_digest ],
        map( ( $_ => $self->$_ ),
            qw( tree_digest author authored_time committer committed_time comment )
        ),
        ( encoding => $self->encoding )x!! $self->encoding !~ /^utf-?8$/,
    };
}

sub _build_fh_using_attributes {
    my ($self) = @_;

    my $content;
    $content .= 'tree ' . $self->tree_digest . "\n";
    $content .= join '', map "parent $_\n", $self->parents_digest
        if $self->has_parents_digest;
    $content .= join(
        ' ',
        author => $self->author->ident,
        $self->authored_time->epoch,
        DateTime::TimeZone->offset_as_string( $self->authored_time->offset )
    ) . "\n";
    $content .= join(
        ' ',
        committer => $self->committer->ident,
        $self->committed_time->epoch,
        DateTime::TimeZone->offset_as_string( $self->committed_time->offset )
    ) . "\n";
    $content .= 'encoding ' . $self->encoding . "\n"
        if $self->encoding !~ /^utf-?8$/i;

    $content .= "\n";
    my $comment = $self->comment;
    chomp $comment;
    $content .= "$comment\n";

    return IO::String->new($content);
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

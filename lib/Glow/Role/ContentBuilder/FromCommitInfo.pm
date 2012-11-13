package Glow::Role::ContentBuilder::FromCommitInfo;
use Moose::Role;
use Glow::Actor;

use Encode qw( decode );

requires '_content_from_trigger';

has commit_info => (
    traits   => ['Hash'],
    is       => 'ro',
    isa      => 'HashRef',
    lazy     => 1,
    required => 0,
    builder => '_build_commit_info',
    trigger => sub { $_[0]->_content_from_trigger('commit_info') },
    handles => {
        map { $_ => [ get => $_ ] }
            qw(
            tree_sha1
            author
            authored_time
            committer
            committed_time
            comment
            encoding
            )
    },
);

sub parents_sha1 { @{ $_[0]->commit_info->{parents_sha1} ||= [] }; }

sub _push_parents_sha1 {
    my ( $self, $sha1 ) = @_;
    push( @{ $self->parent_sha1s }, $sha1 );
}

my %method_map = (
    'tree'      => 'tree_sha1',
    'parent'    => '_push_parents_sha1',
    'author'    => 'authored_time',
    'committer' => 'committed_time'
);

sub _build_commit_info {
    my $self        = shift;
    my $commit_info = { parents_sha1 => [] };

    my @lines = split "\n", $self->content;
    my %header;
    while ( my $line = shift @lines ) {
        last unless $line;
        my ( $key, $value ) = split ' ', $line, 2;
        push @{ $header{$key} }, $value;
    }
    $header{encoding} = ['utf-8'];
    my $encoding = $header{encoding}->[-1];
    for my $key ( keys %header ) {
        for my $value ( @{ $header{$key} } ) {
            $value = decode( $encoding, $value );
            if ( $key eq 'committer' or $key eq 'author' ) {
                my @data = split ' ', $value;
                my ( $email, $epoch, $tz ) = splice( @data, -3 );
                $commit_info->{$key} = Glow::Actor->new(
                    name => join( ' ', @data ),
                    email => substr( $email, 1, -1 ),
                );
                $key = $method_map{$key};
                $commit_info->{$key} = DateTime->from_epoch(
                    epoch     => $epoch,
                    time_zone => $tz
                );
            }
            else {
                $key = $method_map{$key} || $key;
                $commit_info->{$key} = $value;
            }
        }
    }
    $commit_info->{comment} = decode( $encoding, join "\n", @lines );
    return $commit_info;
}

sub _build_fh_using_commit_info {
    my ($self) = @_;
    my $content;
    $content .= 'tree ' . $self->tree_sha1 . "\n";
    $content .= join( ' ', parent => $self->parents_sha1 ) . "\n"
        if $self->parents_sha1;
    $content .= join( ' ',
        author => $self->author->ident,
        $self->authored_time->epoch,
        DateTime::TimeZone->offset_as_string( $self->authored_time->offset )
    ) . "\n";
    $content .= join( ' ',
        committer => $self->committer->ident,
        $self->committed_time->epoch,
        DateTime::TimeZone->offset_as_string( $self->committed_time->offset )
    ) . "\n";
    $content .= "\n";
    my $comment = $self->comment;
    chomp $comment;
    $content .= "$comment\n";

    return IO::String->new($content);
}

1;

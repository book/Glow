package Glow::Role::ContentBuilder::FromTagInfo;
use Moose::Role;
use Glow::Actor;

use Encode qw( decode );

with 'Glow::Role::ContentBuilder';

has tag_info => (
    traits   => ['Hash'],
    is       => 'ro',
    isa      => 'HashRef',
    lazy     => 1,
    required => 0,
    builder  => '_build_tag_info',
    trigger  => sub { $_[0]->_content_from_trigger('tag_info') },
    handles  => {
        map { $_ => [ get => $_ ] }
            qw(
            object
            type
            tag
            tagger
            tagged_time
            comment
            )
    },
);

my %method_map = ( 'tagger' => 'tagged_time' );

sub _build_tag_info {
    my $self     = shift;
    my $tag_info = {};
    my @lines    = split "\n", $self->content;
    while ( my $line = shift @lines ) {
        last unless $line;
        my ( $key, $value ) = split ' ', $line, 2;

        if ( $key eq 'tagger' ) {
            my @data = split ' ', $value;
            my ( $email, $epoch, $tz ) = splice( @data, -3 );
            $tag_info->{$key} = Glow::Actor->new(
                name => join( ' ', @data ),
                email => substr( $email, 1, -1 )
            );
            $tag_info->{ $method_map{$key} } = DateTime->from_epoch(
                epoch     => $epoch,
                time_zone => $tz
            );
        }
        else {
            $tag_info->{ $method_map{$key} || $key } = $value;
        }
    }
    $tag_info->{comment} = join "\n", @lines;
    return $tag_info;
}

sub _build_fh_using_tag_info {
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

1;

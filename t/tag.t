use strict;
use warnings;
use Test::More;
use IO::String;

use Glow::Object::Tag;
use Glow::Actor;
use DateTime;

my $r;
$r = Git::Repository->new( git_dir => 't/git' )
    if eval { require Git::Repository; 1; };

my $file    = 't/content/tag_world';
my $content = do { local $/; local @ARGV = $file; <> };
my $info    = {
    object    => 'ef25e81ba86b7df16956c974c8a9c1ff2eca1326',
    type      => 'commit',
    tag       => 'world',
    tagger    => Glow::Actor->new(
        name  => 'Philippe Bruhat (BooK)',
        email => 'book@cpan.org'
    ),
    tagged_time =>
        DateTime->from_epoch( epoch => 1352846959, time_zone => '+0100' ),
    comment => 'bonjour',
    encoding => 'utf-8',
};

for my $args (
    [ content           => $content ],
    [ content_from_file => $file ],
    [ tag_info          => $info ],
    ( [ git => $r, sha1 => 'f5c10c1a841419d3b1db0c3e0c42b554f9e1eeb2' ] )x!! $r,
    )
{
    my $tag = Glow::Object::Tag->new(@$args);
    is( $tag->kind, 'tag', 'kind' );
    is( join( '', $tag->content_fh->getlines ), $content, 'content_fh' );
    is( $tag->content, $content, 'content' );
    is( $tag->size,    142,      'size' );
    is( $tag->sha1, 'f5c10c1a841419d3b1db0c3e0c42b554f9e1eeb2', 'sha1' );
    # can't use is_deeply here
    my $tag_info = $tag->tag_info;
    for my $attr (qw( object type tag tagged_time comment ) ) {
        is( $tag_info->{$attr}, $info->{$attr}, "commit_info $attr" );
    }
    is( $tag_info->{tagger}->ident, $info->{tagger}->ident, "commit_info tagger" );
}

done_testing;


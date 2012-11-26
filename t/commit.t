use strict;
use warnings;
use Test::More;
use t::Util;

use Glow::Object::Commit;
use Glow::Actor;
use DateTime;

my $r;
$r = Git::Repository->new( git_dir => 't/git' )
    if eval { require Git::Repository; 1; };

my $file    = 't/content/commit_hello';
my $content = do { local $/; local @ARGV = $file; <> };
my $info    = {
    tree_sha1 => 'b52168be5ea341e918a9cbbb76012375170a439f',
    author    => Glow::Actor->new(
        name  => 'Philippe Bruhat (BooK)',
        email => 'book@cpan.org'
    ),
    authored_time =>
        DateTime->from_epoch( epoch => 1352762713, time_zone => '+0100' ),
    committer => Glow::Actor->new(
        name  => 'Philippe Bruhat (BooK)',
        email => 'book@cpan.org'
    ),
    committed_time =>
        DateTime->from_epoch( epoch => 1352764647, time_zone => '+0100' ),
    comment => 'hello',
    encoding => 'utf-8',
};
my $closure = make_closure('t/content/commit_hello');

for my $args (
    [ content           => $content ],
    [ content_from_file => $file ],
    [ commit_info       => $info ],
    [ content_fh_from_closure => $closure],
    ( [ git => $r, sha1 => 'ef25e81ba86b7df16956c974c8a9c1ff2eca1326' ] )x!! $r,
    )
{
    my $commit = Glow::Object::Commit->new(@$args);
    is( $commit->kind, 'commit', 'kind' );
    is( join( '', $commit->content_fh->getlines ), $content, 'content_fh' );
    is( $commit->content, $content, 'content' );
    is( $commit->size,    182,      'size' );
    is( $commit->sha1, 'ef25e81ba86b7df16956c974c8a9c1ff2eca1326', 'sha1' );
    # can't use is_deeply here
    my $commit_info = $commit->commit_info;
    for my $attr (qw( tree_sha1 authored_time committed_time comment ) ) {
        is( $commit_info->{$attr}, $info->{$attr}, "commit_info $attr" );
    }
    for my $attr (qw( author committer ) ) {
        is( $commit_info->{$attr}->ident, $info->{$attr}->ident, "commit_info $attr" );
    }
    is( join( ' ', @{ $commit_info->{parents_sha1} } ),
        join( ' ', @{ $info->{parents_sha1} || [] } ),
        'commit_info parents_sha1'
    );
}

done_testing;


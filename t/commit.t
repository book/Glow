use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Commit;

is( Glow::Mapper->kind2class('commit'),
    'Glow::Object::Commit', 'commit => Glow::Object::Commit' );

for my $test ( @{ $objects{commit} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ commit_info             => $test->{commit_info} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, sha1 => $test->{sha1} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";
        my $commit = Glow::Object::Commit->new(@$args);
        is( $commit->kind, $test->{kind}, 'kind' );
        is( join( '', $commit->content_fh->getlines ),
            $test->{content}, 'content_fh' );
        is( $commit->content, $test->{content}, 'content' );
        is( $commit->size,    $test->{size},    'size' );
        is( $commit->sha1,    $test->{sha1},    'sha1' );

        # can't use is_deeply here
        my $commit_info = $commit->commit_info;
        for my $attr (qw( tree_sha1 authored_time committed_time comment )) {
            is( $commit_info->{$attr},
                $test->{commit_info}{$attr},
                "commit_info $attr"
            );
        }
        for my $attr (qw( author committer )) {
            is( $commit_info->{$attr}->ident,
                $test->{commit_info}{$attr}->ident,
                "commit_info $attr"
            );
        }
        is( join( ' ', @{ $commit_info->{parents_sha1} } ),
            join( ' ', @{ $test->{commit_info}{parents_sha1} || [] } ),
            'commit_info parents_sha1'
        );
    }
}

done_testing;


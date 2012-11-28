use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Tag;

is( Glow::Mapper->kind2class('tag'),
    'Glow::Object::Tag', 'tag => Glow::Object::Tag' );

for my $test ( @{ $objects{tag} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ tag_info                => $test->{tag_info} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, sha1 => $test->{sha1} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";
        my $tag = Glow::Object::Tag->new(@$args);
        is( $tag->kind,                $test->{kind},     'kind' );
        is( $tag->content_fh->getline, $test->{lines}[0], 'content_fh' );
        is( join( '', $tag->content_fh->getlines ),
            $test->{content}, 'content_fh' );
        is( $tag->content, $test->{content}, 'content' );
        is( $tag->size,    $test->{size},    'size' );
        is( $tag->sha1,    $test->{sha1},    'sha1' );

        # can't use is_deeply here
        my $tag_info = $tag->tag_info;
        for my $attr (qw( object type tag tagged_time comment )) {
            is( $tag_info->{$attr},
                $test->{tag_info}{$attr},
                "commit_info $attr"
            );
        }
        is( $tag_info->{tagger}->ident,
            $test->{tag_info}{tagger}->ident,
            "commit_info tagger"
        );
    }
}

done_testing;


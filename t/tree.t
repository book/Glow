use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Tree;

is( Glow::Mapper->kind2class('tree'),
    'Glow::Object::Tree', 'tree => Glow::Object::Tree' );

for my $test ( @{ $objects{tree} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ directory_entries       => $test->{directory_entries} ],
        [ content_from_file       => $test->{file} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, sha1 => $test->{sha1} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";
        my $tree = Glow::Object::Tree->new(@$args);
        is( $tree->kind,                $test->{kind},     'kind' );
        is( $tree->content_fh->getline, $test->{lines}[0], 'content_fh' );
        is( $tree->content,             $test->{content},  'content' );
        is( $tree->size,                $test->{size},     'size' );
        is( $tree->sha1,                $test->{sha1},     'sha1' );
        is_deeply(
            [ $tree->directory_entries ],
            $test->{directory_entries},
            'directory_entries'
        );
    }
}

done_testing;


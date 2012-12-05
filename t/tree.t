use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Tree;

for my $test ( @{ $objects{tree} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ directory_entries       => $test->{directory_entries} ],
        [ content_from_file       => $test->{file} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, digest => $test->{digest} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";

        my $tree = Glow::Object::Tree->new(@$args);
        test_tree( $tree, $test );
    }
}

done_testing;


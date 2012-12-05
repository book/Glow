use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Tag;

for my $test ( @{ $objects{tag} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ tag_info                => $test->{tag_info} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, digest => $test->{digest} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";

        my $tag = Glow::Object::Tag->new(@$args);
        test_tag( $tag, $test );
    }
}

done_testing;


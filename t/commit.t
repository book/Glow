use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Commit;

for my $test ( @{ $objects{commit} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ commit_info             => $test->{commit_info} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, digest => $test->{digest} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";

        my $commit = Glow::Object::Commit->new(@$args);
        test_commit( $commit, $test );
    }
}

done_testing;

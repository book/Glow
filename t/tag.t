use strict;
use warnings;
use Test::More;
use t::TestGit;
our ( %objects, $git );

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

        my $tag = Glow::Repository::Git::Object::Tag->new(@$args);
        test_tag( $tag, $test );
    }
}

done_testing;


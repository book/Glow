use strict;
use warnings;
use Test::More;
use lib 't/lib';
use TestGit;
our ( %objects, $git );

for my $test ( @{ $objects{blob} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, digest => $test->{digest} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";
        my $blob;

        $blob = Glow::Repository::Git::Blob->new(@$args);
        test_blob_mem($blob, $test);

        $blob = Glow::Repository::Git::Blob->new(@$args);
        test_blob_fh($blob, $test);
    }
}

# test some error conditions
diag 'error conditions';
my @errors = (
    [   [ content => 'hello', content_from_file => 't/content/hello' ] =>
            qr/^Can't provide content with content_from_file \(content already provided\)/,
        'content + content_from_file'
    ],
    [   [ content_from_file => 't/content/hello', content => 'hello' ] =>
            qr/^Can't provide content with content_from_file \(content already provided\)/,
        'content_from_file + content'
    ],
);

for my $t (@errors) {
    my ( $args, $error, $mesg ) = @$t;
    ok( !eval { Glow::Repository::Git::Blob->new(@$args); }, $mesg );
    like( $@, $error, 'expected error message' );
}

done_testing;


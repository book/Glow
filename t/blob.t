use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Blob;

is( Glow::Mapper->kind2class('blob'),
    'Glow::Object::Blob', 'blob => Glow::Object::Blob' );

for my $test ( @{ $objects{blob} } ) {
    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, sha1 => $test->{sha1} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";
        my $blob;

        # read content in memory early
        $blob = Glow::Object::Blob->new(@$args);
        is( $blob->kind,                $test->{kind},     'kind' );
        is( $blob->content_fh->getline, $test->{lines}[0], 'content_fh' );
        is( $blob->content,             $test->{content},  'content' );
        is( $blob->size,                $test->{size},     'size' );
        is( $blob->sha1,                $test->{sha1},     'sha1' );

        # do not to read content in memory until the last test
        $blob = Glow::Object::Blob->new(@$args);
        is( $blob->kind,                $test->{kind},     'kind' );
        is( $blob->sha1,                $test->{sha1},     'sha1' );
        is( $blob->size,                $test->{size},     'size' );
        is( $blob->content_fh->getline, $test->{lines}[0], 'content_fh' );
        is( $blob->content,             $test->{content},  'content' );
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
    ok( !eval { Glow::Object::Blob->new(@$args); }, $mesg );
    like( $@, $error, 'expected error message' );
}

done_testing;


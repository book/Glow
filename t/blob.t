use strict;
use warnings;
use Test::More;

use Glow::Object::Blob;
use IO::String;

my @tests = (
    [ content        => 'hello' ],
    [ source         => 't/content/hello' ],
    [ content_source => sub { IO::String->new('hello') } ],
);

for my $args (@tests) {
    my $blob;

    # read content in memory early
    $blob = Glow::Object::Blob->new(@$args);
    is( $blob->kind,                'blob',  'kind' );
    is( $blob->content_fh->getline, 'hello', 'content_fh' );
    is( $blob->content,             'hello', 'content' );
    is( $blob->size,                5,       'size' );
    is( $blob->sha1, 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0', 'sha1' );

    # do not to read content in memory until the last test
    $blob = Glow::Object::Blob->new(@$args);
    is( $blob->kind, 'blob',                                     'kind' );
    is( $blob->sha1, 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0', 'sha1' );
    is( $blob->size, 5,                                          'size' );
    is( $blob->content_fh->getline, 'hello', 'content_fh' );
    is( $blob->content,             'hello', 'content' );
}

# test some error conditions
my $error1 = qr/^At least one but only one of attributes content or content_source is required /;
my $error2 = qr/^Only one of argument source or content_source is allowed /;
my @errors = (
    [ [] => $error1, 'no args' ],
    [   [ content => 'hello', source => 't/content/hello' ] => $error1,
        'content + source'
    ],
    [   [ content => '', content_source => sub { } ] => $error1,
        'content + content_source'
    ],
    [   [ source => 't/content/hello', content_source => sub { } ] => $error2,
        'source + content_source'
    ],
);

for my $t (@errors) {
    my ( $args, $error, $mesg ) = @$t;
    ok( !eval { Glow::Object::Blob->new(@$args); }, $mesg );
    like( $@, $error, 'expected error message' );
}

done_testing;


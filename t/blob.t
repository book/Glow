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
    is( $blob->content_fh->getline, 'hello', 'content' );
    is( $blob->content,             'hello', 'content' );
    is( $blob->size,                5,       'size' );
    is( $blob->sha1, 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0', 'sha1' );

    # do not to read content in memory until the last test
    $blob = Glow::Object::Blob->new(@$args);
    is( $blob->kind, 'blob',                                     'kind' );
    is( $blob->sha1, 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0', 'sha1' );
    is( $blob->size, 5,                                          'size' );
    is( $blob->content_fh->getline, 'hello', 'content' );
    is( $blob->content,             'hello', 'content' );
}

# test some error conditions
my $error_re = qr/^At least one but only one of attributes content or content_source is required /;
ok( !eval { Glow::Object::Blob->new( content => 'hello', source => 't/content/hello' ); }, 'content + source' );
like( $@, $error_re, 'expected error message' );

ok( !eval { Glow::Object::Blob->new(); }, 'no args' );
like( $@, $error_re, 'expected error message' );

done_testing;


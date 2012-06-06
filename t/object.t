use strict;
use warnings;
use Test::More;

use Glow::Object::Blob;

my $blob = Glow::Object::Blob->new( content => 'hello' );
is( $blob->kind,    'blob',                                     'kind' );
is( $blob->size,    5,                                          'size' );
is( $blob->content, 'hello',                                    'content' );
is( $blob->sha1,    'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0', 'sha1' );

# test some error conditions
$error_re = qr/^At least one but only one of attributes content or content_source is required /;
ok( !eval { Glow::Object::Blob->new( content => 'hello', source => 't/hello' ); }, 'content + source' );
like( $@, $error_re, 'expected error message' );

ok( !eval { Glow::Object::Blob->new(); }, 'no args' );
like( $@, $error_re, 'expected error message' );

done_testing;


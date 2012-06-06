use strict;
use warnings;
use Test::More;

use Glow::Object::Blob;

my $blob = Glow::Object::Blob->new( content => 'hello' );
is( $blob->kind,    'blob',                                     'kind' );
is( $blob->size,    5,                                          'size' );
is( $blob->content, 'hello',                                    'content' );
is( $blob->sha1,    'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0', 'sha1' );

done_testing;


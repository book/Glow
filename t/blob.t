use strict;
use warnings;
use Test::More;
use t::TestData;
our %objects;

use Glow::Object::Blob;
is( Glow::Mapper->kind2class('blob'),
    'Glow::Object::Blob', 'blob => Glow::Object::Blob' );

test_blob($_) for @{ $objects{blob} };

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


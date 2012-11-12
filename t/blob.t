use strict;
use warnings;
use Test::More;

use Glow::Object::Blob;

for my $args ( [], [ content => '' ],
    [ content_from_file => 't/content/empty' ], )
{
    my $blob;

    # read content in memory early
    $blob = Glow::Object::Blob->new(@$args);
    is( $blob->kind,                'blob', 'kind' );
    is( $blob->content_fh->getline, undef,  'content_fh' );
    is( $blob->content,             '',     'content' );
    is( $blob->size,                0,      'size' );
    is( $blob->sha1, 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391', 'sha1' );

    # do not to read content in memory until the last test
    $blob = Glow::Object::Blob->new(@$args);
    is( $blob->kind, 'blob',                                     'kind' );
    is( $blob->sha1, 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391', 'sha1' );
    is( $blob->size, 0,                                          'size' );
    is( $blob->content_fh->getline, undef, 'content_fh' );
    is( $blob->content,             '',    'content' );
}

for my $args ( [ content => 'hello' ],
    [ content_from_file => 't/content/hello' ], )
{
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


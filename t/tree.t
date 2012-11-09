use strict;
use warnings;
use Test::More;
use IO::String;

use Glow::Object::Tree;
use Glow::DirectoryEntry;

my ( $tree, $entries, $content );

diag 'empty tree';
for my $args (
    [ content           => '' ],
    [ directory_entries => [] ],
    [ source            => 't/content/empty' ],
    [ content_source    => sub { IO::String->new('') } ],
    )
{
    $tree = Glow::Object::Tree->new(@$args);
    is( $tree->kind,                'tree', 'kind' );
    is( $tree->content_fh->getline, undef,  'content_fh' );
    is( $tree->content,             '',     'content' );
    is( $tree->size,                0,      'size' );
    is( $tree->sha1, '4b825dc642cb6eb9a060e54bf8d69288fbee4904', 'sha1' );
}

diag 'tree with a single file';

$content
    = "100644 hello\0\266\374Lb\13g\331_\225:\\\34\0220\252\253]\265\241\260";
for my $args (
    [ content => $content ],
    [   directory_entries => [
            Glow::DirectoryEntry->new(
                mode     => '100644',
                filename => 'hello',
                sha1     => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0'
            )
        ]
    ],
    [ source         => 't/content/tree_hello' ],
    [ content_source => sub { IO::String->new($content) } ],
    )
{
    $tree = Glow::Object::Tree->new(@$args);
    is( $tree->kind,                'tree',   'kind' );
    is( $tree->content_fh->getline, $content, 'content_fh' );
    is( $tree->content,             $content, 'content' );
    is( $tree->size,                33,       'size' );
    is( $tree->sha1, 'b52168be5ea341e918a9cbbb76012375170a439f', 'sha1' );
}

done_testing;


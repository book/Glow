use strict;
use warnings;
use Test::More;
use t::TestData;
our ( %objects, $git );

use Glow::Object::Tree;
use Glow::DirectoryEntry;

is( Glow::Mapper->kind2class('tree'),
    'Glow::Object::Tree', 'tree => Glow::Object::Tree' );

my $r;
$r = Git::Repository->new( git_dir => 't/git' )
    if eval { require Git::Repository; 1; };

for my $args (
    [],
    [ content           => '' ],
    [ directory_entries => [] ],
    [ content_from_file => 't/content/empty' ],
    [ content_fh_from_closure => make_closure('t/content/empty') ],
    ( [ git => $r, sha1 => '4b825dc642cb6eb9a060e54bf8d69288fbee4904' ] )x!! $r,
    )
{
    diag 'empty tree with ' . ( $args->[0] || 'nothing' );
    my $tree = Glow::Object::Tree->new(@$args);
    is( $tree->kind,                'tree', 'kind' );
    is( $tree->content_fh->getline, undef,  'content_fh' );
    is( $tree->content,             '',     'content' );
    is( $tree->size,                0,      'size' );
    is( $tree->sha1, '4b825dc642cb6eb9a060e54bf8d69288fbee4904', 'sha1' );
    is_deeply( [ $tree->directory_entries ], [], 'directory_entries' );
}

my $content
    = "100644 hello\0\266\374Lb\13g\331_\225:\\\34\0220\252\253]\265\241\260";
my $entries = [
    Glow::DirectoryEntry->new(
        mode     => '100644',
        filename => 'hello',
        sha1     => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0'
    )
];
for my $args (
    [ content           => $content ],
    [ directory_entries => $entries ],
    [ content_from_file => 't/content/tree_hello' ],
    [ content_fh_from_closure => make_closure('t/content/tree_hello') ],
    ( [ git => $r, sha1 => 'b52168be5ea341e918a9cbbb76012375170a439f' ] )x!! $r,
    )
{
    diag "hello tree with $args->[0]";
    my $tree = Glow::Object::Tree->new(@$args);
    is( $tree->kind,                'tree',   'kind' );
    is( $tree->content_fh->getline, $content, 'content_fh' );
    is( $tree->content,             $content, 'content' );
    is( $tree->size,                33,       'size' );
    is( $tree->sha1, 'b52168be5ea341e918a9cbbb76012375170a439f', 'sha1' );
    is_deeply( [ $tree->directory_entries ], $entries, 'directory_entries' );
}

done_testing;


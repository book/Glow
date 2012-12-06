use strict;
use warnings;
use Glow::Repository::Git;
use Glow::DirectoryEntry;
use Glow::Actor;
use DateTime;

# helper routines
sub make_closure {
    my $filename = shift;
    return sub {
        open my $fh, '<', $filename or die "Can't open $filename: $!";
        return $fh;
    };
}

# test data
our %objects = (
    blob => [
        {   desc    => 'empty blob',
            content => '',
            file    => 't/content/empty',
            digest  => 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391',
        },
        {   desc    => 'hello blob',
            content => 'hello',
            file    => 't/content/hello',
            digest  => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0',
        },
    ],
    tree => [
        {   desc              => 'empty tree',
            directory_entries => [],
            content           => '',
            file              => 't/content/empty',
            digest            => '4b825dc642cb6eb9a060e54bf8d69288fbee4904',
        },
        {   desc              => 'hello tree',
            directory_entries => [
                Glow::DirectoryEntry->new(
                    mode     => '100644',
                    filename => 'hello',
                    digest   => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0'
                )
            ],
            content =>
                "100644 hello\0\266\374Lb\13g\331_\225:\\\34\0220\252\253]\265\241\260",
            string =>
                "100644 blob b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0\thello\n",
            file   => 't/content/tree_hello',
            digest => 'b52168be5ea341e918a9cbbb76012375170a439f',
        },
        {   desc              => 'tree with subtree',
            directory_entries => [
                Glow::DirectoryEntry->new(
                    mode     => '100644',
                    filename => 'hello',
                    digest   => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0'
                ),
                Glow::DirectoryEntry->new(
                    mode     => '40000',
                    filename => 'subdir',
                    digest   => 'b52168be5ea341e918a9cbbb76012375170a439f'
                ),
            ],
            content =>
                "100644 hello\0\266\374Lb\13g\331_\225:\\\34\0220\252\253]\265\241\26040000 subdir\0\265!h\276^\243A\351\30\251\313\273v\1#u\27\nC\237",
            string =>
                "100644 blob b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0\thello\n040000 tree b52168be5ea341e918a9cbbb76012375170a439f\tsubdir\n",
            file   => 't/content/tree_subdir',
            digest => '71ff52fcd190c0a900fffad2ecf2f678554602b6',
        },
        {   desc => 'tree with subtree (unsorted directory_entries)',
            directory_entries => [
                Glow::DirectoryEntry->new(
                    mode     => '40000',
                    filename => 'subdir',
                    digest   => 'b52168be5ea341e918a9cbbb76012375170a439f'
                ),
                Glow::DirectoryEntry->new(
                    mode     => '100644',
                    filename => 'hello',
                    digest   => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0'
                ),
            ],
            content =>
                "100644 hello\0\266\374Lb\13g\331_\225:\\\34\0220\252\253]\265\241\26040000 subdir\0\265!h\276^\243A\351\30\251\313\273v\1#u\27\nC\237",
            string =>
                "100644 blob b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0\thello\n040000 tree b52168be5ea341e918a9cbbb76012375170a439f\tsubdir\n",
            file   => 't/content/tree_subdir',
            digest => '71ff52fcd190c0a900fffad2ecf2f678554602b6',
        },
    ],
    commit => [
        {   desc        => 'hello commit',
            commit_info => {
                tree_digest => 'b52168be5ea341e918a9cbbb76012375170a439f',
                author      => Glow::Actor->new(
                    name  => 'Philippe Bruhat (BooK)',
                    email => 'book@cpan.org'
                ),
                authored_time => DateTime->from_epoch(
                    epoch     => 1352762713,
                    time_zone => '+0100'
                ),
                committer => Glow::Actor->new(
                    name  => 'Philippe Bruhat (BooK)',
                    email => 'book@cpan.org'
                ),
                committed_time => DateTime->from_epoch(
                    epoch     => 1352764647,
                    time_zone => '+0100'
                ),
                comment  => 'hello',
                encoding => 'utf-8',
            },
            content => << 'COMMIT',
tree b52168be5ea341e918a9cbbb76012375170a439f
author Philippe Bruhat (BooK) <book@cpan.org> 1352762713 +0100
committer Philippe Bruhat (BooK) <book@cpan.org> 1352764647 +0100

hello
COMMIT
            file   => 't/content/commit_hello',
            digest => 'ef25e81ba86b7df16956c974c8a9c1ff2eca1326',
        },
        {   desc        => 'commit with a parent',
            commit_info => {
                tree_digest => '71ff52fcd190c0a900fffad2ecf2f678554602b6',
                parents_digest =>
                    ['ef25e81ba86b7df16956c974c8a9c1ff2eca1326'],
                author => Glow::Actor->new(
                    name  => 'Philippe Bruhat (BooK)',
                    email => 'book@cpan.org'
                ),
                authored_time => DateTime->from_epoch(
                    epoch     => 1352766313,
                    time_zone => '+0100'
                ),
                committer => Glow::Actor->new(
                    name  => 'Philippe Bruhat (BooK)',
                    email => 'book@cpan.org'
                ),
                committed_time => DateTime->from_epoch(
                    epoch     => 1352766360,
                    time_zone => '+0100'
                ),
                comment  => 'say hi to parent!',
                encoding => 'utf-8',
            },
            content => << 'COMMIT',
tree 71ff52fcd190c0a900fffad2ecf2f678554602b6
parent ef25e81ba86b7df16956c974c8a9c1ff2eca1326
author Philippe Bruhat (BooK) <book@cpan.org> 1352766313 +0100
committer Philippe Bruhat (BooK) <book@cpan.org> 1352766360 +0100

say hi to parent!
COMMIT
            file   => 't/content/commit_say_hi',
            digest => '3a4098405fa5a807b2306e345dda70d33d229c91',
        },
    ],
    tag => [
        {   desc     => 'world tag',
            tag_info => {
                object => 'ef25e81ba86b7df16956c974c8a9c1ff2eca1326',
                type   => 'commit',
                tag    => 'world',
                tagger => Glow::Actor->new(
                    name  => 'Philippe Bruhat (BooK)',
                    email => 'book@cpan.org'
                ),
                tagged_time => DateTime->from_epoch(
                    epoch     => 1352846959,
                    time_zone => '+0100'
                ),
                comment  => 'bonjour',
                encoding => 'utf-8',
            },
            content => << 'TAG',
object ef25e81ba86b7df16956c974c8a9c1ff2eca1326
type commit
tag world
tagger Philippe Bruhat (BooK) <book@cpan.org> 1352846959 +0100

bonjour
TAG
            file   => 't/content/tag_world',
            digest => 'f5c10c1a841419d3b1db0c3e0c42b554f9e1eeb2',
        }
    ],
);

# add extra information
for my $kind ( keys %objects ) {
    for my $object ( @{ $objects{$kind} } ) {
        $object->{kind}    = $kind;
        $object->{sha1}    = $object->{digest};
        $object->{size}    = length $object->{content};
        $object->{closure} = make_closure( $object->{file} );
        $object->{lines}   = [ split /^/m, $object->{content} ];
        $object->{string} ||= $object->{content};
    }
}

# can we interact with git?
our $git;
$git = eval { Git::Repository->new( git_dir => 't/git' ) }
    if eval { require Git::Repository; 1; };

# test routines
sub test_blob_mem {
    my ( $blob, $test ) = @_;

    # read content in memory early
    isa_ok( $blob, 'Glow::Repository::Git::Object::Blob' );
    is( $blob->kind,                $test->{kind},     'kind' );
    is( $blob->content,             $test->{content},  'content' );
    is( $blob->content_fh->getline, $test->{lines}[0], 'content_fh' );
    is( $blob->size,                $test->{size},     'size' );
    is( $blob->digest,              $test->{digest},   'digest' );
    is( $blob->sha1,                $test->{sha1},     'sha1' );
    is( $blob->as_string,           $test->{string},   'as_string' );
}

sub test_blob_fh {
    my ( $blob, $test ) = @_;

    # do not to read content in memory until the last test
    isa_ok( $blob, 'Glow::Repository::Git::Object::Blob' );
    is( $blob->kind,                $test->{kind},     'kind' );
    is( $blob->digest,              $test->{digest},   'digest' );
    is( $blob->sha1,                $test->{sha1},     'sha1' );
    is( $blob->size,                $test->{size},     'size' );
    is( $blob->content_fh->getline, $test->{lines}[0], 'content_fh' );
    is( $blob->content,             $test->{content},  'content' );
}

sub test_tree {
    my ( $tree, $test ) = @_;

    isa_ok( $tree, 'Glow::Repository::Git::Object::Tree' );
    is( join( '', $tree->content_fh->getlines ),
        $test->{content}, 'content_fh' );
    is( $tree->kind,    $test->{kind},    'kind' );
    is( $tree->content, $test->{content}, 'content' );
    is( $tree->size,    $test->{size},    'size' );
    is( $tree->digest,  $test->{digest},  'digest' );
    is( $tree->sha1,    $test->{sha1},    'sha1' );
    is_deeply(
        [ $tree->directory_entries ],
        [   sort { $a->filename cmp $b->filename }
                @{ $test->{directory_entries} }
        ],
        'directory_entries'
    );
    is( $tree->as_string, $test->{string}, 'as_string' );
}

sub test_commit {
    my ( $commit, $test ) = @_;

    isa_ok( $commit, 'Glow::Repository::Git::Object::Commit' );
    is( $commit->kind, $test->{kind}, 'kind' );
    is( join( '', $commit->content_fh->getlines ),
        $test->{content}, 'content_fh' );
    is( $commit->content, $test->{content}, 'content' );
    is( $commit->size,    $test->{size},    'size' );
    is( $commit->digest,  $test->{digest},  'digest' );
    is( $commit->sha1,    $test->{sha1},    'sha1' );

    # can't use is_deeply here
    my $commit_info = $commit->commit_info;
    for my $attr (qw( tree_digest authored_time committed_time comment )) {
        is( $commit_info->{$attr},
            $test->{commit_info}{$attr},
            "commit_info $attr"
        );
    }
    for my $attr (qw( author committer )) {
        is( $commit_info->{$attr}->ident,
            $test->{commit_info}{$attr}->ident,
            "commit_info $attr"
        );
    }
    is( join( ' ', @{ $commit_info->{parents_digest} } ),
        join( ' ', @{ $test->{commit_info}{parents_digest} || [] } ),
        'commit_info parents_digest'
    );
    is( $commit->as_string, $test->{string}, 'as_string' );
}

sub test_tag {
    my ( $tag, $test ) = @_;

    isa_ok( $tag, 'Glow::Repository::Git::Object::Tag' );
    is( $tag->kind,                $test->{kind},     'kind' );
    is( $tag->content_fh->getline, $test->{lines}[0], 'content_fh' );
    is( join( '', $tag->content_fh->getlines ),
        $test->{content}, 'content_fh' );
    is( $tag->content, $test->{content}, 'content' );
    is( $tag->size,    $test->{size},    'size' );
    is( $tag->digest,  $test->{digest},  'digest' );
    is( $tag->sha1,    $test->{sha1},    'sha1' );

    # can't use is_deeply here
    my $tag_info = $tag->tag_info;
    for my $attr (qw( object type tag tagged_time comment )) {
        is( $tag_info->{$attr},
            $test->{tag_info}{$attr},
            "commit_info $attr"
        );
    }
    is( $tag_info->{tagger}->ident,
        $test->{tag_info}{tagger}->ident,
        "commit_info tagger"
    );
    is( $tag->as_string, $test->{string}, 'as_string' );
}

1;

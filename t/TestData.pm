use strict;
use warnings;
use Glow::DirectoryEntry;
use Glow::Object::Commit;
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
            sha1    => 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391',
        },
        {   desc    => 'hello blob',
            content => 'hello',
            file    => 't/content/hello',
            sha1    => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0',
        },
    ],
    tree => [
        {   desc              => 'empty tree',
            directory_entries => [],
            content           => '',
            file              => 't/content/empty',
            sha1              => '4b825dc642cb6eb9a060e54bf8d69288fbee4904',
        },
        {   desc              => 'hello tree',
            directory_entries => [
                Glow::DirectoryEntry->new(
                    mode     => '100644',
                    filename => 'hello',
                    sha1     => 'b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0'
                )
            ],
            content =>
                "100644 hello\0\266\374Lb\13g\331_\225:\\\34\0220\252\253]\265\241\260",
            file => 't/content/tree_hello',
            sha1 => 'b52168be5ea341e918a9cbbb76012375170a439f',
        }

    ],
    commit => [
        {   desc        => 'hello commit',
            commit_info => {
                tree_sha1 => 'b52168be5ea341e918a9cbbb76012375170a439f',
                author    => Glow::Actor->new(
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
            file => 't/content/commit_hello',
            sha1 => 'ef25e81ba86b7df16956c974c8a9c1ff2eca1326',
        }
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
            file => 't/content/tag_world',
            sha1 => 'f5c10c1a841419d3b1db0c3e0c42b554f9e1eeb2',
        }
    ],
);

# add extra information
for my $kind ( keys %objects ) {
    for my $object ( @{ $objects{$kind} } ) {
        $object->{kind}    = $kind;
        $object->{size}    = length $object->{content};
        $object->{closure} = make_closure( $object->{file} );
        $object->{lines}   = [ split /^/m, $object->{content} ];
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
    isa_ok( $blob, 'Glow::Object::Blob' );
    is( $blob->kind,                $test->{kind},     'kind' );
    is( $blob->content,             $test->{content},  'content' );
    is( $blob->content_fh->getline, $test->{lines}[0], 'content_fh' );
    is( $blob->size,                $test->{size},     'size' );
    is( $blob->sha1,                $test->{sha1},     'sha1' );
}

sub test_blob_fh  {
    my ( $blob, $test ) = @_;

    # do not to read content in memory until the last test
    isa_ok( $blob, 'Glow::Object::Blob' );
    is( $blob->kind,                $test->{kind},     'kind' );
    is( $blob->sha1,                $test->{sha1},     'sha1' );
    is( $blob->size,                $test->{size},     'size' );
    is( $blob->content_fh->getline, $test->{lines}[0], 'content_fh' );
    is( $blob->content,             $test->{content},  'content' );
}

sub test_tree {
    my ($test) = @_;
    require Glow::Object::Tree;

    for my $args (
        [ content                 => $test->{content} ],
        [ directory_entries       => $test->{directory_entries} ],
        [ content_from_file       => $test->{file} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, sha1 => $test->{sha1} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";

        my $tree = Glow::Object::Tree->new(@$args);
        is( $tree->kind, $test->{kind}, 'kind' );
        is( join( '', $tree->content_fh->getlines ),
            $test->{content}, 'content_fh' );
        is( $tree->content, $test->{content}, 'content' );
        is( $tree->size,    $test->{size},    'size' );
        is( $tree->sha1,    $test->{sha1},    'sha1' );
        is_deeply(
            [ $tree->directory_entries ],
            $test->{directory_entries},
            'directory_entries'
        );
    }
}

sub test_commit {
    my ($test) = @_;
    require Glow::Object::Commit;

    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ commit_info             => $test->{commit_info} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, sha1 => $test->{sha1} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";

        my $commit = Glow::Object::Commit->new(@$args);
        is( $commit->kind, $test->{kind}, 'kind' );
        is( join( '', $commit->content_fh->getlines ),
            $test->{content}, 'content_fh' );
        is( $commit->content, $test->{content}, 'content' );
        is( $commit->size,    $test->{size},    'size' );
        is( $commit->sha1,    $test->{sha1},    'sha1' );

        # can't use is_deeply here
        my $commit_info = $commit->commit_info;
        for my $attr (qw( tree_sha1 authored_time committed_time comment )) {
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
        is( join( ' ', @{ $commit_info->{parents_sha1} } ),
            join( ' ', @{ $test->{commit_info}{parents_sha1} || [] } ),
            'commit_info parents_sha1'
        );
    }
}

sub test_tag {
    my ($test) = @_;
    require Glow::Object::Tag;

    for my $args (
        [ content                 => $test->{content} ],
        [ content_from_file       => $test->{file} ],
        [ tag_info                => $test->{tag_info} ],
        [ content_fh_from_closure => $test->{closure} ],
        ( [ git => $git, sha1 => $test->{sha1} ] )x!! $git
        )
    {
        diag "$test->{desc} with $args->[0]";

        my $tag = Glow::Object::Tag->new(@$args);
        is( $tag->kind,                $test->{kind},     'kind' );
        is( $tag->content_fh->getline, $test->{lines}[0], 'content_fh' );
        is( join( '', $tag->content_fh->getlines ),
            $test->{content}, 'content_fh' );
        is( $tag->content, $test->{content}, 'content' );
        is( $tag->size,    $test->{size},    'size' );
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
    }
}

1;

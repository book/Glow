use strict;
use warnings;
use Glow::DirectoryEntry;
use Glow::Object::Commit;
use Glow::Actor;
use DateTime;

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

1;

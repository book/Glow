use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use t::TestGit;
our ( %objects, %test_func );

use Glow::Repository::Git::Storage::Pack;

# packs with indexes
my @packs = (
    't/git/objects/pack/pack-bf2c6ed91d2760533ddad29a2f0939fe04b3b115.pack');

# copy them as packs without index
{
    my $tempdir = tempdir( CLEANUP => 1 );
    my $file = "$tempdir/pack-bf2c6ed91d2760533ddad29a2f0939fe04b3b115.pack";
    open my $fh, $packs[0] or die "$!";
    open my $gh, '>', $file or die "$!";
    local $/;
    print {$gh} <$fh>;
    push @packs, $file;
}

# a pack to read from
@packs = map Glow::Repository::Git::Storage::Pack->new( filename => $_ ),
    @packs;

my %pack_contains = map { $_ => 1 } qw(
    3a4098405fa5a807b2306e345dda70d33d229c91
    71ff52fcd190c0a900fffad2ecf2f678554602b6
    9d94853f1733007321288974bce2cec5bb07a6df
    b52168be5ea341e918a9cbbb76012375170a439f
    b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0
    ef25e81ba86b7df16956c974c8a9c1ff2eca1326
    f5c10c1a841419d3b1db0c3e0c42b554f9e1eeb2
);

for my $pack (@packs) {
    diag $pack->filename;
    for my $test ( map @$_, values %objects ) {
        no strict 'refs';
        diag "$test->{kind} $test->{digest}";

        if ( $pack_contains{ $test->{digest} } ) {
            ok( $pack->has_object( $test->{digest} ), 'has_object' );

            # load the object
            my $object = $pack->get_object( $test->{digest} );
            &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };
        }
        else {
            ok( !$pack->has_object( $test->{digest} ), '!has_object' );
        }
    }
}

# check that we can't add to a pack
ok( !$packs[0]->put_object(
        Glow::Repository::Git::Object::Blob->new( content => 'hello' )
    ),
    '!put_object'
);

done_testing;


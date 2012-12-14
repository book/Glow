use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use t::TestGit;
our ( %objects, %test_func );

use Glow::Repository::Git::Storage::Pack;

my @packs = (
    't/git/objects/pack/pack-e035dc88ab4715cd92e3dd206751c7ae3830a97d.pack');
{
    my $tempdir = tempdir( CLEANUP => 1 );
    my $file = "$tempdir/pack-e035dc88ab4715cd92e3dd206751c7ae3830a97d.pack";
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
    ef25e81ba86b7df16956c974c8a9c1ff2eca1326
    f5c10c1a841419d3b1db0c3e0c42b554f9e1eeb2
    b52168be5ea341e918a9cbbb76012375170a439f
    b6fc4c620b67d95f953a5c1c1230aaab5db5a1b0
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

done_testing;


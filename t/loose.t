use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use t::TestGit;
our %objects;

# a loose backend to read from
my $loose_r = Glow::Repository::Git::Storage::Loose->new(
    directory => 't/git/objects' );

# a loose backend to write to
my $loose_w = Glow::Repository::Git::Storage::Loose->new(
    directory => tempdir( CLEANUP => 1 ) );

my %test_func = (
    blob   => [qw( test_blob_mem test_blob_fh)],
    tree   => [qw( test_tree )],
    commit => [qw( test_commit )],
    tag    => [qw( test_tag )],
    none   => [qw( test_none )],
);

for my $test ( map @$_, values %objects ) {
    no strict 'refs';
    diag "$test->{kind} $test->{digest}";

    # load the object
    my $object = $loose_r->get_object( $test->{digest} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };

    # don't test saving non-objects
    next if $test->{kind} eq 'none';

    # save the object
    $loose_w->put_object($object);

    # read it again
    $object = $loose_w->get_object( $test->{digest} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };
}

done_testing;


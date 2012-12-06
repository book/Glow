use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use t::TestGit;
our %objects;

use Glow::Repository;

# a repository to read from
my $r = Glow::Repository->new( directory => 't/git' );
isa_ok( $r, 'Glow::Repository::Git' );

# a repository to write to
my $w = Glow::Repository::Git->new(
    directory => tempdir( CLEANUP => 1 ) );

my %test_func = (
    blob   => [qw( test_blob_mem test_blob_fh)],
    tree   => [qw( test_tree )],
    commit => [qw( test_commit )],
    tag    => [qw( test_tag )],
);

# quick test of the config
my %config = (
    'core.repositoryformatversion' => 0,
    'core.filemode'                => 'true',
    'core.bare'                    => 'true',
    'dummy.naught'                 => undef,
);

for my $key ( sort keys %config ) {
    is( $r->config->get( key => $key ), $config{$key}, $key );
}

# test reading and writing data
for my $test ( map @$_, values %objects ) {
    no strict 'refs';
    diag "$test->{kind} $test->{digest}";

    # load the object
    my $object = $r->get_object( $test->{digest} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };

    # save the object
    $w->put_object($object);

    # read it again
    $object = $w->get_object( $test->{digest} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };
}

done_testing;


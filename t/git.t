use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use t::TestGit;
our ( %objects, %test_func );

use Glow::Repository;

# a repository to read from
my $r = Glow::Repository->new( 't/git' );
isa_ok( $r, 'Glow::Repository::Git' );

# a repository to write to
my $w = Glow::Repository::Git->new(
    directory => tempdir( CLEANUP => 1 ) );

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
my %stored;
for my $test ( map @$_, values %objects ) {
    no strict 'refs';
    diag "$test->{kind} $test->{digest}";

    ok( $r->has_object( $test->{digest} ) x!! $test->{kind} ne 'none',
        'has_object' );

    # load the object
    my $object = $r->get_object( $test->{digest} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };

    # don't test saving non-objects
    next if $test->{kind} eq 'none';

    is( $w->has_object( $test->{digest} ),
        !!$stored{ $test->{digest} },
        'has_object yet'
    );

    # save the object
    $w->put_object($object);
    $stored{ $object->digest }++;
    ok( $w->has_object( $test->{digest} ), 'has_object now' );

    # read it again
    $object = $w->get_object( $test->{digest} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };
}

done_testing;

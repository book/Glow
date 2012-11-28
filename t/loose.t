use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use t::TestData;
our %objects;

use Glow::Backend::Loose;
use Glow::Object::Blob;      # must register
use Glow::Object::Tree;      # must register
use Glow::Object::Commit;    # must register
use Glow::Object::Tag;       # must register

# a loose backend to read from
my $loose_r = Glow::Backend::Loose->new( directory => 't/git/objects' );

# a loose backend to write to
my $loose_w = Glow::Backend::Loose->new( directory => tempdir( CLEANUP => 1 ) );

my %test_func = (
    blob   => [qw( test_blob_mem test_blob_fh)],
    tree   => [qw( test_tree )],
    commit => [qw( test_commit )],
    tag    => [qw( test_tag )],
);

for my $test ( map @$_, values %objects ) {
    no strict 'refs';
    diag "$test->{kind} $test->{sha1}";

    # load the object
    my $object = $loose_r->get_object( $test->{sha1} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };

    # save the object
    $loose_w->put_object( $object );

    # read it again
    $object = $loose_w->get_object( $test->{sha1} );
    &$_( $object, $test ) for @{ $test_func{ $test->{kind} } };
}

done_testing;


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

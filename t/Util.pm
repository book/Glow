sub make_closure {
    my $filename = shift;
    return sub {
        open my $fh, '<', $filename or die "Can't open $filename: $!";
        return $fh;
    };
}

1;

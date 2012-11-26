package Glow::Mapper;
use strict;
use warnings;

my %kind2class;

sub register_mapping {
    my ( $self, $kind, $class ) = @_;
    warn "Replacing $kind => $kind2class{$kind} mapping with $kind => $class"
        if exists $kind2class{$kind};
    $kind2class{$kind} = $class;
}

sub kind2class {
    my ( $self, $kind ) = @_;
    die "No kind to class mapping found for $kind"
        if !exists $kind2class{$kind};
    return $kind2class{$kind};
}

1;


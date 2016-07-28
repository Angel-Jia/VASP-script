#!/bin/env perl
use warnings;
use strict;
use vars qw($line %element @ele_order);

open IN, '<', $ARGV[0];

while(defined($line = <IN>)){
    $line =~ s/^\s+//;
    my @tmp = split(/\s+/, $line);

    if(exists $element{$tmp[0]}){
        push(@{$element{$tmp[0]}}, $line);
    }else{
        push(@{$element{$tmp[0]}}, $line);
        push(@ele_order, $tmp[0]);
    }
    
}
close(IN);

open OUT, '>', $ARGV[0];
for(my $i = 0; $i < @ele_order; $i++){
    print OUT @{$element{$ele_order[$i]}};
}
close(OUT);

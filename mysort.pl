#!/bin/env perl
use strict;
use vars qw(@C_chain $C_chain @H_chain $C_chain $line);

open IN, '<', $ARGV[0];

@C_chain = ();
@H_chain = ();

while(defined($line = <IN>)){
    $line =~ s/^\s//;
    if ($line =~ /^C/){
        push(@C_chain, $line);
    }else{
        push(@H_chain, $line);
    }
}
close(IN);

open OUT, '>', "output";
print OUT @C_chain;
print OUT @H_chain;
close(OUT);

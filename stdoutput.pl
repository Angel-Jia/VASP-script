#!/usr/bin/env perl
#
#version 1.0
use 5.010;
use warnings;
use strict;
use vars qw($line);
$ARGV[0]='INPUT' if $ARGV[0] eq '';
$ARGV[1]='OUTPUT' if $ARGV[1] eq '';
open IN, '<', $ARGV[0] or die "Cannot open file $ARGV[0]: $!\n";
open OUT, '>', $ARGV[1] or die "Cannot open file $ARGV[1]: $!\n";
while(defined($line = <IN>)){
  chomp($line);
  $line =~ s/^\s+//;
  my @output = split(/\s+/,$line);
  if($line =~ /[a-zA-Z]/){
    print OUT ($line);
  }else{
    for(my $i=0; $i<@output; $i++){
      printf OUT ("%20.9f",$output[$i]);
    }
}
  print OUT ("\n");
}
close(IN);
close(OUT);
print "results now have been saved in file $ARGV[1].\n";
$line=<stdin>;

#!/usr/bin/env perl
#This script produce MODECAR for vasp vtst tool
#by sky, Energy&Environmental Catakysis Research Group, nankai university
#version 1.0
#date 2015-3-12

use 5.010;
use FindBin qw($Bin);
use lib "$Bin";
print "\n";
print "\n";
print "################ This script makes MODECAR file for vasp vtst tool ################";
print "\n";
print "\n";


if(!defined($ARGV[0])  or @ARGV != 2){
    print "Usage: freq.pl freqfile factor....\n";
    print "Please try again!\n";
    print "\n";
    die;
}

$freqfile = shift(@ARGV);
$factor = pop(@ARGV);
print "                             processing....\n";

open IN, '<', $freqfile or die "Cannot open file $freqfile: $!\n";
open OUT, '>', MODECAR or die "Cannot creat file MODECAR: $!\n";
chomp(@freq_file = <IN>);
close(IN);
$index = 0;
while($freq_file[$index] =~ s/^\s+//){
    if($freq_file[$index] =~ /dx/){
        $index += 1;
        last;
    }
    $index += 1;
}
die "freq file is incorrect!"  if($index >= @freq_file);

while($freq_file[$index] =~ /[0-9]/){
    $freq_file[$index] =~ s/^\s+//;
    @line = split(/\s+/, $freq_file[$index]);
    printf OUT "    %10.6f    %10.6f    %10.6f\n", $line[3]*$factor,
               $line[4]*$factor, $line[5]*$factor;
    $index++;
}

print "\n";
print "                         ----------- Done -----------\n";
print "\n";
print "\n";

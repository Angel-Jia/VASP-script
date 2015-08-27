#!/bin/env perl
#This script is used to replace POSCARs in each folder of images with standard gvfile
#by sky,Energy&Environmental Catalysis Research Group, Nankai University, Tianjin
#version 1.0

use 5.010;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use vars qw($filename $pos_file $coo $basis $lattice 
            $natoms $totatoms $selectiveflag $selective $description $filetype &read_gvfile);

print "\n";
print "\n";
print "############### This script converts vasp file into gview file ###############\n";
print "\n";


if($ARGV[0] eq "" or @ARGV < 2){
    print "Usage: nebtrans.pl POSCAR gvfile1 gvfile2 .... \n";
    print "Please try again!\n";
    print "\n";
    exit 1;
}

$pos_file = shift(@ARGV);
($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
= read_poscar($pos_file);

while($ARGV[0]){
    my $filename = shift(@ARGV);
    my $output;

    $output = $filename;
    $output =~ s/\.gjf/\.vasp/;

    print "                            Processing $output\n";
    read_gvfile($filename);
    $coo = kardir($coo,$basis,$lattice,$totatoms);
    write_carposcar($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,
                    $selective,$description,$output,$filetype);
     
}


sub read_gvfile {
    my $line;
    my @line;
    my $index = 0;
    my $label = 100;
    my $j;
    my @tmp;
    my $input = shift;
    open IN, '<', "$input" or die "cannot open file $input: $!\n";
    @line = <IN>;
    close(IN);
    while(defined($line[$index])){
        chomp($line[$index]);
        $line[$index] =~ s/^\s+//;
        if($line[$index] eq "" and $label == 100){
            $index = $index + 4;
            $label = $index;
            next;
        }elsif($line[$index] eq "" and $label != 100){
            last;
        }
        if($index >= $label){
            @tmp = split(/\s+/, $line[$index]);
            for($j=0;$j<3;$j++){
                $coo->[$index-$label][$j]=$tmp[$j+1];
            }
        }
    $index++;
    }
}
print "\n";
print "              --------------------  DONE  --------------------\n";
print "\n";

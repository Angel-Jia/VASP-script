#!/bin/env perl
#This script is used to replace POSCARs in each folder of images with standard gvfile
#by sky,Energy&Environmental Catalysis Research Group, Nankai University, Tianjin
#version 1.0

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

    print "                             Processing $output\n";
    read_gvfile($filename);
    $coo = kardir($coo,$basis,$lattice,$totatoms);
    write_carposcar($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,
                    $selective,$description,$output,$filetype);
     
}


sub read_gvfile {
    my @line;
    my $index = 0;
    my $begin_line;
    my @tmp;
    my $input = shift;
    my @element;
    my @atoms_num;

    open IN, '<', "$input" or die "cannot open file $input: $!\n";

    @line = <IN>;
    close(IN);

    while(defined($line[$index])){
        chomp($line[$index]);
        $line[$index] =~ s/^\s+//;

        #Find the beginning of coordinates
        if($line[$index] =~ /^[0-9]\s+[0-9]\s*$/){
            $index++;
            $begin_line = $index;
            next;
        }
        if(!defined($begin_line)){
            $index++;
            next;
        }
        #in case of blank line at the end of file
        last if($line[$index] =~ /^$/);

        @tmp = split(/\s+/, $line[$index]);

        #initialise @element
        if(!defined($element[0])){
            push(@element, $tmp[0]);
            push(@atoms_num, 0);
        }

        if($tmp[0] eq $element[-1]){
            $atoms_num[-1]++;
        }else{
            push(@element, $tmp[0]);
            push(@atoms_num, 1);
        }
        
        for(my $j = 0; $j < 3; $j++){
            $coo->[$index - $begin_line][$j] = $tmp[$j + 1];
        }
        $index++;
    }

    $totatoms = 0;
    $description = "";
    @{$natoms} = ();
    for(my $i = 0; $i < @element; $i++){
        $description = $description."  ".$element[$i];
        $natoms->[$i] = $atoms_num[$i];
        $totatoms += $atoms_num[$i];
    }
    $description =~ s/^\s+//;
}
print "\n";
print "               --------------------  DONE  --------------------\n";
print "\n";

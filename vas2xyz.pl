#!/usr/bin/env perl
#This script converts vasp file into .xyz file
#by sky nankai university
#version 1.0
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use strict;
use vars qw($input $output $coo $basis $lattice $natoms $totatoms $selectiveflag $selective $description $filetype @element $element);

print "\n";
print "\n";
print "############### This script converts vasp file into .xyz file ###############\n";
print "             ############ CONTCAR or POSCAR -> .xyz ############\n";
print "\n";


# Get the input parameters
if(defined($ARGV[0]) == 0){
    print "Usage: vas2xyz.pl INPUTFILE1 INPUTFILE2 INPUTFILE3.....\n";
    print "INPUTFILE can be POSCAR or CONTCAR and either direct ot cartesian\n";
    print "Please try again!\n";
    print "\n";
    print "\n";
    exit 1;
}

while($ARGV[0]){
    my $m=0;
    my $n=0;
    my $j=0;
    $input = shift @ARGV;
    $output = $input.".xyz";
    print "                            Processing $output\n";

    ($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
     = read_poscar($input);
    
    $coo = dirkar($coo,$basis,$lattice,$totatoms);
    @element = split(/\s+/, $description);
    open OUT, '>', $output or die "cannot creat file $output: $!\n";
    print OUT $totatoms;
    print OUT "\n";
    print OUT "creat from vasp file";
    print OUT "\n";

    for($m = 0; $m < @element; $m++){
        for($n = 0; $n < ($natoms->[$m]); $n++){
            printf OUT "%2s", $element[$m];
            printf OUT "    %20.16f    %20.16f    %20.16f\n", $coo->[$j][0], $coo->[$j][1], $coo->[$j][2];
            $j++;
        }
    }
    print OUT "\n";
    close(OUT);
}
print "\n";
print "              --------------------- DONE ---------------------\n";
print "\n";

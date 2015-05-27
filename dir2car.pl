#!/usr/bin/env perl
#This script converts direct to cartesian
#by sky nankai university
#version 1.0
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use strict;
use vars qw($input $output $coo $basis $lattice $natoms $totatoms $selectiveflag $selective $description $filetype);

print "\n";
print "\n";
print "############This script noly converts direct to cartesian############\n";
print "\n";
# Get the input parameters
if($ARGV[0] eq ""){
print "Usage: dir2car.pl INPUTFILE1 INPUTFILE2 INPUTFILE3.....\n";
print "Please try again!\n";
print "\n";
print "\n";
exit 1;
}

while(defined($ARGV[0])){
    $input = shift(@ARGV);
    $output = $input."-C.vasp";


    ($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
     = read_poscar($input);

    write_carposcar($coo,$basis,$lattice,$natoms,$totatoms,
                 $selectiveflag,$selective,$description,"$output",$filetype);
    print "    $input completed!\n";
}
print "\n";
print "########################Convertion finished!########################\n";
print "\n";

#!/usr/bin/env perl
#by sky nankai university
#version 1.0
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use strict;
use warnings;
use vars qw($input $output $coo $coo1 $basis $lattice $natoms $totatoms $selectiveflag $selective $description $filetype $model $vasp_file $basis1 $lattice1 $natoms1 $totatoms1 $selectiveflag1);

print "\n";
print "\n";
print "############ This script changes T and F according to model file ############\n";
print "\n";

# Get the input parameters
if(!defined($ARGV[0])){
    print "Usage: flachg.pl modelfile vaspfile \n";
    print "Please try again!\n";
    print "\n";
    print "\n";
    exit 1;
}

$model = shift(@ARGV);

while(defined($ARGV[0])){

$vasp_file = shift(@ARGV);
print "                             Processing  $vasp_file\n";

($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
 = read_poscar($vasp_file);

($coo1,$basis1,$lattice1,$natoms1,$totatoms1,$selectiveflag1,$selective,$description,$filetype)
 = read_poscar($model);

if($totatoms != $totatoms1){
    print "                    TOTAL NUMBER OF ATOMS IN $vasp_file IS: $totatoms\n";
    print "                    TOTAL NUMBER OF ATOMS IN $model IS: $totatoms1\n";
    die;
}

write_carposcar($coo,$basis,$lattice,$natoms,$totatoms,
             $selectiveflag,$selective,$description,"$vasp_file",$filetype);
}

print "\n";
print "                     --------------- Done ---------------\n";
print "\n";

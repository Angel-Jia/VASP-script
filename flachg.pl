#!/usr/bin/env perl
#This script converts direct to cartesian
#by sky nankai university
#version 1.0
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use strict;
use vars qw($input $output $coo $coo1 $basis $lattice $natoms $totatoms $selectiveflag $selective $description $filetype $model $vasp_file);

print "\n";
print "\n";
print "############This script noly converts direct to cartesian############\n";
print "\n";
# Get the input parameters
if($ARGV[0] eq ""){
print "Usage: flachg.pl modelfile vaspfile \n";
print "Please try again!\n";
print "\n";
print "\n";
exit 1;
}

$model = shift(@ARGV);
$vasp_file = shift(@ARGV);


($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
 = read_poscar($vasp_file);

($coo1,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
 = read_poscar($model);

write_carposcar($coo,$basis,$lattice,$natoms,$totatoms,
             $selectiveflag,$selective,$description,"$vasp_file",$filetype);

print "    $input completed!\n";
print "\n";
print "########################Convertion finished!########################\n";
print "\n";

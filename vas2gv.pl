#!/usr/bin/env perl
#This script converts vasp file into gview file
#by sky nankai university
#version 1.0
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use strict;
use warnings;
use vars qw($input $output $coo $basis $lattice $natoms $totatoms $selectiveflag $selective $description $filetype @element $element);

print "\n";
print "\n";
print "############### This script converts vasp file into gview file ###############\n";
print "             ############ CONTCAR or POSCAR -> .gjf ############\n";
print "\n";

# Get the input parameters
if(!defined($ARGV[0])){
    print "Usage: vas2gv.pl file1 file2 file3.....\n";
    print "file can be POSCAR or CONTCAR and either direct or cartesian\n";
    print "Please try again!\n";
    print "\n";
    print "\n";
    exit 1;
}

while(defined($ARGV[0])){
    $input = shift @ARGV;
    $output = $input.".gjf";
    print "                             Processing $input\n";

    ($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
     = read_poscar($input);
    
    $coo = dirkar($coo,$basis,$lattice,$totatoms);
    @element = split(/\s+/, $description);
    open OUT, '>', $output or die "cannot creat file $output: $!\n";
    print OUT "# opt freq b3lyp/6-31g\n";
    print OUT "\n";
    print OUT "creat from vasp file\n";
    print OUT "\n";
    print OUT "0 1\n";

    for(my $m = 0, my $j = 0; $m < @element; $m++){
        for(my $n = 0; $n < ($natoms->[$m]); $n++){
            printf OUT "%2s", $element[$m];
            printf OUT "    %20.16f    %20.16f    %20.16f\n", $coo->[$j][0], $coo->[$j][1], $coo->[$j][2];
            $j++;
        }
    }
    print OUT "\n";
    close(OUT);
}
print "\n";
print "                     --------------- Done ---------------\n";
print "\n";

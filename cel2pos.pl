#!/bin/env perl
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use strict;
use vars qw($coo $basis $lattice $natoms @natoms $totatoms $selectiveflag $selective $description $filetype $coordinationflag @element $element $line $line_num);

print "\n";
print "\n";
print "################## This script converts .cell into POSCAR ##################\n";
print "              ############### .cell -> POSCAR ###############\n";
print "\n";


if(!defined($ARGV[0])){
    print "Usage: cel2pos.pl file\n";
    print "Please try again\n";
    print "\n";
    print "\n";
    exit 1;
}

print "                            Processing...\n";

open IN, '<', $ARGV[0] or die "cannot creat file $ARGV[0]: $!\n";
open OUT, '>', "POSCAR" or die "cannot creat file POSCAR: $!\n";

$line_num = 0;
while(defined($line = <IN>)){
    $line_num++;
    chomp($line);
    $line =~ s/^\s+//;
    if($line_num >= 2 and $line_num <= 4){
        my @line_sp = split(/\s+/,$line);
        $basis->[0][$line_num-2] = $line_sp[0];
        $basis->[1][$line_num-2] = $line_sp[1];
        $basis->[2][$line_num-2] = $line_sp[2];
        next;
    }
    
    next if($line_num <= 7);

    if($line_num > 7){
        last if($line =~ /^\%/);
        my @line_sp = split(/\s+/,$line);
        if(!defined($element[0])){
            push(@element,$line_sp[0]);
            push(@natoms,1);
        }elsif($line_sp[0] eq $element[-1]){
            $natoms[-1]++;
        }else{
            push(@element,$line_sp[0]);
            push(@natoms,1);
        }
        $coo->[$line_num-8][0]=$line_sp[1];
        $coo->[$line_num-8][1]=$line_sp[2];
        $coo->[$line_num-8][2]=$line_sp[3];
    }
}

$lattice = "   1.00000000000000";
for(my $i = 0, $totatoms = 0; $i < @natoms; $i++){
    $totatoms += $natoms[$i];
}
$natoms = \@natoms;
$selectiveflag = "Selective dynamics";

for(my $i = 1, $description = "$element[0]"; $i < @element; $i++){
    $description = "$description  $element[$i]";
}

$filetype = "vasp5";
for(my $i = 0; $i < $totatoms; $i++){
    $selective ->[$i] = "  T T T";
}

write_poscar($coo,$basis,$lattice,$natoms,$totatoms,
         $selectiveflag,$selective,$description,"POSCAR",$filetype);
    


close(IN);
close(OUT);


print "\n";
print "                  ----------------- Done -----------------\n";
print "\n";

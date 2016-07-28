#!/usr/bin/env perl
#This script produce .xyz file involving vibration animation
#Each frequency should be saved as a individual file, an extra POSCAR is needed
#by sky, Energy&Environmental Catakysis Research Group, nankai university
#version 1.0
#date 2014-11-28

use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
print "\n";
print "\n";
print "################ This script makes animation of vibration ################\n";
print "\n";



sub writefile {
    printf OUT "%d\n", $totatoms;
    printf OUT "file number: %d\n", $count+1;
    for($m = 0; $m < @element; $m++){
        for($n = 0; $n < ($natoms->[$m]); $n++){
            if($coordination[$j][0] == 0){
                printf OUT "%2s", $element[$m];
                printf OUT "    %20.16f    %20.16f    %20.16f\n", $coordination[$j][1],
                         $coordination[$j][2], $coordination[$j][3];
                $j++;
            }else{
                $coordination[$j][1] += $coordination[$j][4] * $sign;
                $coordination[$j][2] += $coordination[$j][5] * $sign;
                $coordination[$j][3] += $coordination[$j][6] * $sign;
                printf OUT "%2s", $element[$m];
                printf OUT "    %20.16f    %20.16f    %20.16f\n", $coordination[$j][1],
                         $coordination[$j][2], $coordination[$j][3];
                $j++;
            }

        }
    }
}


if(!defined($ARGV[0]) or @ARGV < 4){
    print "Usage: freq.pl POSCAR freq1 freq2...freqN number factor....\n";
    print "Please try again!\n";
    print "\n";
    die;
}

$file_pos = shift(@ARGV);
$factor = pop(@ARGV);
$number = pop(@ARGV);

($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
 = read_poscar($file_pos);
@element = split(/\s+/, $description);





while(defined($ARGV[0])){
    $freq_in = shift(@ARGV);
    $freq_out = $freq_in.".xyz";
    print "                          Processing $freq_in\n";

    open IN, '<', $freq_in or die "Cannot open file $freq_in: $!\n";
    open OUT, '>', $freq_out or die "Cannot open file $freq_out: $!\n";
    chomp(@freq_file = <IN>);
    close(IN);
    $index = 0;
    @coordination = ();
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
	if($line[3] == 0 && $line[4] == 0 && $line[5] == 0){
	    unshift(@line,0);
	}else{
	    unshift(@line,1);
            #This is a mark, the line remians the same will be marked by 0
	    $line[4] = $line[4] * $factor / $number;
	    $line[5] = $line[5] * $factor / $number;
	    $line[6] = $line[6] * $factor / $number;
	}
        push(@coordination, [@line]);
        $index += 1;
    }

    die "the number of atoms is different" if(@coordination != $totatoms);

    $count = 0;#animation number
    while($count < $number*4){
        $j = 0;
        if($count == 0){
            $sign = 0;
            writefile;
            $count++;
        }elsif($count <= $number){
        #0->1
            $sign = 1.0;
            writefile;
            $count++;
        }elsif($count > $number && $count <= $number*3){
        #1->-1
            $sign = -1.0;
            writefile;
            $count++;
        }else{
        #-1->0
            $sign = 1.0;
            writefile;
            $count++;
        }
    }
}
print "\n";
print "                ------------------ Done ------------------\n";
print "\n";
print "\n";

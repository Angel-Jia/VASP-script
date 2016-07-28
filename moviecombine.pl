#!/usr/bin/env perl
#this script use movie.xyz made by xdat2xyz.pl to make movie in whcih all images are compared
#by sky nankai university
#version 1.0
use warnings;
print "\n";
print "\n";
print "###############This script merges all input .xyz file###############\n";
print "\n";
if(!defined($ARGV[0])){
    print "Usage: moviecombine.pl file1 file2 file3 ..... fileN OUTPUT X Y Z\n";
    print "The file must be standard .xyz file\n";
    print "Please try again!\n";
    exit 1;
}

$z_shift = pop(@ARGV);
$y_shift = pop(@ARGV);
$x_shift = pop(@ARGV);
$filename = pop(@ARGV);

open OUT, '>', $filename or die "Cannot open file $filename: $!\n";
for(my $i = 0; $i < @ARGV; $i++){
    open IN, '<', $ARGV[$i] or die "Cannot open file $ARGV[$i]: $!\n";
    chomp(@line = <IN>);
    push(@file, [@line]);
    close(IN);
}

#$total_atoms: atoms in OUTPUT file
#$file_atoms: atoms in different INPUT file
for(my $i = 0; $i < @ARGV; $i++){
    $file_atoms[$i] = $file[$i][0];
    $total_atoms += $file[$i][0];
}

#$i stands for different file
#@index: which line in different INPUT file
#reading from the third line
for(my $i = 0; $i < @ARGV; $i++){
    $index[$i] = 0;
}
$step = 1;
while($file[0][$index[0]+1]){
    print OUT $total_atoms,"\n";
    print OUT "step: $step\n";
    for($i = 0; $i < @ARGV; $i++){
        $limit[$i] = $index[$i] + $file_atoms[$i] + 2;
        $index[$i] += 2;
        while($index[$i] < $limit[$i]){
            $file[$i][$index[$i]] =~ s/^\s+//;
            @tmp = split(/\s+/, $file[$i][$index[$i]]);
            #set shift, separating images from each other
            $tmp[1] = $tmp[1] + $x_shift * $i;
            $tmp[2] = $tmp[2] + $y_shift * $i;
            $tmp[3] = $tmp[3] + $z_shift * $i;
            printf OUT "%2s  %15.10f  %15.10f %15.10f\n",$tmp[0],$tmp[1],$tmp[2],$tmp[3];
            $index[$i]++;
        }
    }
    $step++;
}

close(OUT);
print "              ###############Finished!###############\n";
print "\n";

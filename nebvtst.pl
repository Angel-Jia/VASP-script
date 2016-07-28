#!/bin/env perl
#this script is used to get infomation about energy, distance, forece
#matching for vasp-vtst tool
#by sky,Energy&Environmental Catalysis Research Group, Nankai University, Tianjin
#version 1.0


use strict;
use warnings;
use vars qw($steps $steps_count $images $foldercount $foldername $ENER $DIST $TANG $FORC @energy 
            @distance_prev @distance_next @angle @tangentforce @force &read_file);

print "\n";
print "\n";
print "##########This script is used to get information about energy, distance, force##########\n";
print "\n";
print "\n";


if(!defined($ARGV[0])){
    print "Usage: vtstnebforce.pl images \n";
    print "Please try again!\n";
    print "\n";
    exit 1;
}

$images = $ARGV[0];
$foldercount = 1;

while($foldercount <= $images){
    my @tmp;
    if($foldercount < 10){
	$foldername = "0$foldercount";
    }else{
        $foldername = $foldercount;
    }

    print "Processing folder$foldername \n";

    `grep "free  energy" $foldername/OUTCAR >$foldername/energy.tmp`;
    `grep "distance to prev" $foldername/OUTCAR >$foldername/distance.tmp`;
    `grep "projections on to tangent" $foldername/OUTCAR >$foldername/tangentforce.tmp`;
    `grep "FORCES: max atom" $foldername/OUTCAR >$foldername/force.tmp`;


    open $ENER, '<', "$foldername/energy.tmp" or die "$foldername/energy.tmp: $!";
    open $DIST, '<', "$foldername/distance.tmp" or die "$foldername/distance.tmp: $!";
    open $TANG, '<', "$foldername/tangentforce.tmp" or die "$foldername/tangentforce.tmp: $!";
    open $FORC, '<', "$foldername/force.tmp" or die "$foldername/force.tmp: $!";

    @tmp = read_file($ENER, 4);
    push(@energy, [@tmp]);
    @tmp = ();

    @tmp = read_file($DIST, 8);
    push(@distance_prev,[@tmp]);
    @tmp = ();
    @tmp = read_file($DIST, 9);
    push(@distance_next,[@tmp]);
    @tmp = ();
    @tmp = read_file($DIST, 10);
    push(@angle,[@tmp]);
    @tmp = ();

    @tmp = read_file($TANG, 8);
    push(@tangentforce,[@tmp]);
    @tmp = ();

    @tmp = read_file($FORC, 4);
    push(@force,[@tmp]);
    $steps = @tmp;
    @tmp = ();

    close($ENER);
    close($DIST);
    close($TANG);
    close($FORC);
    $foldercount++;
    `rm -rf $foldername/*.tmp 2> /dev/null`;
}


print "\n";
$steps_count=0;
while($steps_count < $steps){
    printf "steps: %d\n", $steps_count+1;
    my $images_count = 0;
    while($images_count < $images){
#        if($images_count == 0){
#            printf "              dist: %8.5f  angle: %10.5f \n",$distance_prev[0][$steps_count],
#                  $angle[0][$steps_count];
#            }
            printf "images: %d    ", $images_count+1;
            printf "%10.5f  %10.5f  %10.5f\n",$energy[$images_count][$steps_count],
                  $tangentforce[$images_count][$steps_count],$force[$images_count][$steps_count];
#            printf "              dist: %8.5f  angle: %10.5f \n",
#                  $distance_next[$images_count][$steps_count],
#                  $angle[$images_count][$steps_count];
    $images_count++;
    }
    $steps_count++;
    print "\n";

}




sub read_file {
    my $file = shift;
    my $location = shift;
    my @tmpline;
    my $count = 0;
    my @result;
    my $line;
    seek($file,0,0);
    while(defined($line = <$file>)){
        chomp($line);
        $line =~ s/^\s+//;
	@tmpline = split(/\s+/, $line);
        $result[$count] = $tmpline[$location];
	$count++;
    }
    return @result;
}

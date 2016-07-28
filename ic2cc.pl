#!/bin/env perl
use strict;
use warnings;
use vars qw($num $coor $c_coor $line);
use Math::Trig;

#cross product
sub cross{
    my $v1 = shift;
    my $v2 = shift;
    my $v;
    $v->[0] = $v1->[1] * $v2->[2] - $v2->[1] * $v1->[2];
    $v->[1] = $v2->[0] * $v1->[2] - $v1->[0] * $v2->[2];
    $v->[2] = $v1->[0] * $v2->[1] - $v2->[0] * $v1->[1];
    return $v;
}

sub dot{
    my $v1 = shift;
    my $v2 = shift;
    return $v1->[0] * $v2->[0] + $v1->[1] * $v2->[1] + $v1->[2] * $v2->[2];
}

#scalar x vector
sub scalvect{
    my $scal = shift;
    my $v = shift;
    my $vresult;
    for(my $i = 0; $i <= 2; $i++){
        $vresult->[$i] = $scal * $v->[$i];
    }
    return $vresult;
}

sub add{
    my $v1 = shift;
    my $v2 = shift;
    my $v;
    for(my $i = 0; $i <= 2; $i++){
        $v->[$i] = $v1->[$i] + $v2->[$i];
    }
    return $v;
}

sub subtract{
    my $v1 = shift;
    my $v2 = shift;
    my $v;
    for(my $i = 0; $i <= 2; $i++){
        $v->[$i] = $v1->[$i] - $v2->[$i];
    }
    return $v;
}

#Rodrigues' rotation formula
sub ro_rotation{
    my $rotatev = shift;
    my $beta = shift;
    my $point = shift;
    my $unit;

    $beta = deg2rad($beta);

    #unit
    my $len = sqrt(dot($rotatev, $rotatev));
    for(my $i = 0; $i <= 2; $i++){
        $unit->[$i] = $rotatev->[$i] / $len;
    }

    my $first = scalvect(cos($beta), $point);
    my $sec = scalvect(sin($beta), cross($unit, $point));
    my $third = scalvect(dot($unit, $point) * (1 - cos($beta)), $unit);
    
    return add($first, add($sec, $third));
}

#use NeRF Method
sub innertoc{
    my $coor1 = shift;  #distance
    my $coor2 = shift;  #angle between tow bonds
    my $coor3 = shift;  #dihedral angle
    my $inner_coo = shift;
    my $coor;

    #First, placing the new atom a bond length away from the previous atom in line 
    #with the previous bond axis

    #unit
    my $vect12 = subtract($coor1, $coor2);
    my $len = sqrt(dot($vect12, $vect12));
    my $unit;
    for(my $i = 0; $i <= 2; $i++){
        $unit->[$i] = $vect12->[$i] / $len;
    }
    #add unit*distance to atom1 to get the new atom
    for(my $i = 0; $i <= 2; $i++){
        $coor->[$i] = $unit->[$i] * $inner_coo->[0] + $coor1->[$i];
    }

    #Second, put atoms to the origin of the coordinate
    my $trans_coor = $coor1;
    my $coor1_re = subtract($coor1, $trans_coor);
    my $coor2_re = subtract($coor2, $trans_coor);
    my $coor3_re = subtract($coor3, $trans_coor);
    my $coor_re = subtract($coor, $trans_coor);

    #rotate the new atom, setting the angle between the two bonds
    #normal vector
    my $normal = cross(subtract($coor2, $coor3), subtract($coor1, $coor2));
    $coor_re = ro_rotation($normal, 180 - $inner_coo->[1], $coor_re);

    #rotate the new atom arount the vect atom1-atom2
    $coor_re = ro_rotation(subtract($coor1_re, $coor2_re), $inner_coo->[2], $coor_re);

    return add($coor_re, $trans_coor);
}

if(!defined($ARGV[0])){
    print "Usage: ic2cc.pl coordinate_file\n";
    print "The first three line in coordinate_file must be cartesian coordinate.\n";
    print "Please try again!\n";
    print "\n";
    die;
}

open COOR, '<', $ARGV[0] or die "cannot open file $ARGV[0]: $!\n";
open OUT, '>', $ARGV[0].".car" or die "cannot creat file output: $!\n";


#read coordinates
$num= 0;
while(defined($line = <COOR>)){
    chomp($line);
    $line =~ s/^\s+//;
    last if $line =~ /^$/;
    $num++;
    if($num <= 3){
        my @tmp = split(/\s+/, $line);
        for(my $i = 0; $i <= 3; $i++){
            $coor->[$num - 1][$i] = $tmp[$i];
        }
    }else{
        my @tmp = split(/\s+/, $line);
        for(my $i = 0; $i <= 6; $i++){
            $coor->[$num - 1][$i] = $tmp[$i];
        }
    }
}

die "Wrong coordinates\n" if($num < 4);

for(my $i = 0; $i <=2; $i++){
    $c_coor->[$i] = $coor->[$i];
}

#Convert coordinates
for(my $i = 3; $i < $num; $i++){
    my $coor1;
    my $coor2;
    my $coor3;
    my $inner;
    for(my $j = 0; $j <= 2; $j++){
        $coor1->[$j] = $c_coor->[$coor->[$i][1] - 1][$j + 1];
        $coor2->[$j] = $c_coor->[$coor->[$i][3] - 1][$j + 1];
        $coor3->[$j] = $c_coor->[$coor->[$i][5] - 1][$j + 1];
    }

    $inner->[0] = $coor->[$i][2];
    $inner->[1] = $coor->[$i][4];
    $inner->[2] = $coor->[$i][6];

    $c_coor->[$i][0] = $coor->[$i][0];
    my $tmp = innertoc($coor1, $coor2, $coor3, $inner);
    for(my $j = 1; $j <= 3; $j++){
        $c_coor->[$i][$j] = $tmp->[$j - 1];
    }
}

for(my $i = 0; $i < $num; $i++){
    printf OUT "%2s    %20.16f    %20.16f    %20.16f\n", $c_coor->[$i][0],
           $c_coor->[$i][1], $c_coor->[$i][2], $c_coor->[$i][3];
}
print OUT "\n";

close(COOR);
close(OUT);

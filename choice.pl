#!/bin/env perl
use strict;
use Math::Trig;
use vars qw($file $line @eachline $coor $O $i $array @array);

sub dot {
    my $v1 = shift;
    my $v2 = shift;
    return $v1->[0]*$v2->[0]+$v1->[1]*$v2->[1]+$v1->[2]*$v2->[2];
}

sub angle {
    my $v1 = shift;
    my $v2 = shift;
    return rad2deg(acos(dot($v1,$v2)/(sqrt(dot($v1,$v1))*sqrt(dot($v2,$v2)))));
}

sub substra {
    my $v1 = shift;
    my $v2 = shift;
    return [$v2->[0]-$v1->[0],$v2->[1]-$v1->[1],$v2->[2]-$v1->[2]];
}

sub add {
    my $v1 = shift;
    my $v2 = shift;
    return [$v2->[0]+$v1->[0],$v2->[1]+$v1->[1],$v2->[2]+$v1->[2]];
}

sub midvt {
    my $v1 = shift;
    my $v2 = shift;
    my $v3 = shift;
    my $half = [[0.5,0.5,0.5]];
    return substra(add(dot(substra($v1,$v2),$half),$v1),$v3);
}


open IN,'<',$ARGV[0] or die;

$i = 0;
while($line=<IN>){
    chomp $line;
    @eachline=split(/\s+/,$line);
    $coor->[$i][0] = $eachline[1];
    $coor->[$i][1] = $eachline[2];
    $coor->[$i][2] = $eachline[3];
    $i++;
}
close(IN);
close(OUT);

for(my $i=0;$i<4;$i++){
    for(my $j=0;$j<4;$j++){
    next if($j==$i);
    my $v1=substra($coor->[$i],$coor->[$i+4]);
    my $v2=substra($coor->[$i],$coor->[$j]);
    #print "$i  $j\n";
    #print "$v1->[0]  $v1->[1]  $v1->[2]\n";
    #print "$v2->[0]  $v2->[1]  $v2->[2]\n";
    $O->[$i][$j]=angle($v1,$v2);
    #print "$O->[$i][$j]\n";
    }
}



@array=(
["1","2","3","4","1"],
["1","4","3","2","1"],
["1","2","4","3","1"],
["1","3","4","2","1"],
["1","3","2","4","1"],
["1","4","2","3","1"],
);

for(my $i=0;$i<6;$i++){
    my $j=0;
    while($j<6){
    print "$array[$i][$j]   ";
    $j++;
    }
    print "\n";
    print "$O->[0][$array[$i][1]-1];  $O->[$array[$i][1]-1][$array[$i][2]-1];  $O->[$array[$i][2]-1][$array[$i][3]-1];  $O->[$array[$i][3]-1][$array[$i][4]-1];\n";
    print "\n";
}
#data
#O1
#O2
#O3
#O4
#Sn1
#Si2
#Si3
#Si4
#
#
#
##possibility
#12341
#12431
#
#13241
#13421
#
#14231
#14321

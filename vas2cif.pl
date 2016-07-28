#!/bin/env perl
use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use strict;
use warnings;
use Math::Trig;
use vars qw($input $output $coo $basis $lattice $natoms $totatoms $selectiveflag $selective $description $filetype @element $element);

print "\n";
print "\n";
print "############### This script converts vasp file into cif file ###############\n";
print "            ############ CONTCAR or POSCAR -> .cif ############\n";
print "\n";

if(!defined($ARGV[0])){
    print "Usage: pos2cif.pl file1 file2 file3.....\n";
    print "file can be POSCAR or CONTCAR and either direct or cartesian\n";
    print "Please try again!\n";
    print "\n";
    print "\n";
    exit 1;
}

#product of two vectors
sub dot {
    my $v1 = shift;
    my $v2 = shift;
    return $v1->[0]*$v2->[0]+$v1->[1]*$v2->[1]+$v1->[2]*$v2->[2]
}

#angle between tow vectors
sub angle {
    my $v1 = shift;
    my $v2 = shift;
    return rad2deg(acos(dot($v1,$v2)/(sqrt(dot($v1,$v1))*sqrt(dot($v2,$v2)))));
}


while(defined($ARGV[0])){
    my $va;
    my $vb;
    my $vc;
    my $length_a;
    my $length_b;
    my $length_c;
    my $alpha;
    my $beta;
    my $gamma;

    $input = shift @ARGV;
    $output = $input.".cif";
    print "                            Processing $input\n";
    ($coo,$basis,$lattice,$natoms,$totatoms,$selectiveflag,$selective,$description,$filetype)
     = read_poscar($input);

    for(my $i = 0; $i < 3; $i++){
            $va->[$i] = $basis->[$i][0];
            $vb->[$i] = $basis->[$i][1];
            $vc->[$i] = $basis->[$i][2];
    }

    $length_a = sqrt(dot($va,$va));
    $length_b = sqrt(dot($vb,$vb));
    $length_c = sqrt(dot($vc,$vc));

    $alpha = angle($vb,$vc);
    $beta = angle($vc,$va);
    $gamma = angle($va,$vb);

    open OUT, '>', $output or die "cannot creat file $output: $!\n";

    print OUT "data_\n";
    print OUT "_audit_creation_method    'Materials Studio'\n";
    printf OUT "_cell_length_a  %15.6f\n", $length_a;
    printf OUT "_cell_length_b  %15.6f\n", $length_b;
    printf OUT "_cell_length_c  %15.6f\n", $length_c;
    printf OUT "_cell_angle_alpha  %10.6f\n", $alpha;
    printf OUT "_cell_angle_beta   %10.6f\n", $beta;
    printf OUT "_cell_angle_gamma  %10.6f\n", $gamma;
    print OUT "_symmetry_space_group_name_H-M  'P1'\n";
    print OUT "loop_\n";
    print OUT "_atom_site_type_symbol\n";
    print OUT "_atom_site_label\n";
    print OUT "_atom_site_fract_x\n";
    print OUT "_atom_site_fract_y\n";
    print OUT "_atom_site_fract_z\n";

    @element = split(/\s+/, $description);
    for(my $m = 0, my $count = 0; $m < @element; $m++){
        for(my $n = 0; $n < ($natoms->[$m]); $n++){
            $count++;
            printf OUT " %6s %6s", $element[$m], $element[$m];
            printf OUT "%-8s", $count;
            for(my $i = 0; $i < 3; $i++){
                my $coord = $coo->[$count-1][$i];
                if ($coord>1) { $coord -= 1; }
                elsif ($coord<0) { $coord += 1; }
                printf OUT "%20.16f", $coord;
            }
            print OUT "\n";
        }
    } 
    close(OUT);
}
print "\n";
print "                    --------------- Done ---------------\n";
print "\n";
print "\n";

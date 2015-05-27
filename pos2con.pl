#!/usr/bin/env perl
#;-*- Perl -*-

use FindBin qw($Bin);
use lib "$Bin";
use Vasp;
use Math::Trig;
$fact = 180/pi;

@args = @ARGV;
@args >= 1 || die "usage: pos2con.pl <POSCAR or CON file>\n";
$inputfilename = $args[0];
$filetype = "vasp";

$inputfile = "";
open (IN,$inputfilename);
while (<IN>) { $inputfile .= $_; }
close (IN);

@inputfile = split(/\n/,$inputfile);
foreach(@inputfile) { $_ =~ s/^\s+//; }
$header = $inputfile[0];

if($inputfilename =~ /\.con/i) {$filetype = "con";}

if($filetype eq "con")
{
    print "\nConverting con to vasp\n";
    $descript = $inputfile[9];

    $box = $inputfile[2];
    @box = split(/\s+/,$box);
    $ang = $inputfile[3];
    @ang = split(/\s+/,$ang);
    $scale = $box[0];
    for($i=0; $i<3; $i++){
        $box[$i] = $box[$i]/$scale;
        $arad[$i] = $ang[$i]/$fact;
    }
    $orthogonal = ($ang[0]==90 && $ang[1]==90 && $ang[2]==90)?1:0;
    if(!$orthogonal){print "non-orthogonal\n";}

    $v2[0] = $ang[0]==90?0:cos($arad[0]);
    $v2[1] = $ang[0]==90?1:sin($arad[0]);
    $v3[0] = $ang[1]==90?0:cos($arad[1]);
    $v3[1] = ($ang[1]==90 && $ang[2]==90)?0:(cos($arad[2])-$v2[0]*$v3[0])/$v2[1];
    $v3[2] = sqrt(1.0-$v3[0]**2-$v3[1]**2);

    $v2[0] *= $box[1];
    $v2[1] *= $box[1];
    $v3[0] *= $box[2];
    $v3[1] *= $box[2];
    $v3[2] *= $box[2];

    $ntypes = $inputfile[6];
    $ntypes =~ s/\s+.*//g;

    $natoms = $inputfile[7];
    @natoms = split(/\s+/,$natoms);
    $totatoms = 0;
    for ($i=0; $i<$ntypes; $i++) {
        $totatoms += $natoms[$i];
    }
    $natoms=join("   ",@natoms[0..$ntypes-1]);

    @coords2 = @inputfile[11 .. 11+$totatoms-1+2*($ntypes-1)];
    @coords = ();
    $natomsold = 0;
    $atomtypes = "";
    for ($i=0; $i<$ntypes; $i++) {
        print "...\n";
        @line=split(/\s+/,$inputfile[9+$natomsold]);
        if(scalar(@line) > 0) {
            $atomtypes .= @line[0]." ";
        } else {
            $atype = "Type"."$i"." ";
        }
        $natomsnow = $natoms[$i];
        @coords = (@coords,@coords2[$natomsold..$natomsold+$natomsnow-1]);
        $natomsold += $natomsnow + 2;
    }

    # Read coordinates
    for($i=0; $i<@coords; $i++) {
        @line = split(/\s+/,$coords[$i]);
        for($j=0; $j<3; $j++) {
            $line[$j] = $line[$j]/$scale;
        }
        if(!$orthogonal) {
            @v = @line[0..2];
            $line[2] = $v[2]/$v3[2];
            $v[1] -= $v3[1]*$line[2];
            $v[0] -= $v3[0]*$line[2];
            $line[1] = $v[1]/$v2[1];
            $v[0] -= $v2[0]*$line[1];
            $line[0] = $v[0];
        } else {
            $line[1] /= $v2[1];
            $line[2] /= $v3[2];
        }
        if($line[3] == 1) {
            $line[3] = "F F F";
        } else {
            $line[3] = "T T T";
        }
        $coords[$i] = join("   ",@line[0..3]);
    }

    $head = $atomtypes."\n";
    $head .= $scale."\n";
    $head .= "1    0    0\n";
    $head .= "$v2[0]    $v2[1]    0\n";
    $head .= "$v3[0]    $v3[1]    $v3[2]\n";
    $head .= $atomtypes."\n"; # uncomment for vasp5 default
    $head .= $natoms."\nSelective dynamics\nDirect\n";
    $file = $head.join("\n",@coords)."\n";
    if(@args >= 2) {
        $outputfilename = $args[1];
    } else {
        $outputfilename = $inputfilename;
        $outputfilename =~ s/.con//;
    }
    open (OUT,">$outputfilename");
    print OUT $file;
    close (OUT);
}

if($filetype eq "vasp")
{
    print "\nConverting vasp to con\n";
    @header = split(/\s+/,$header);

    ($coordinates,$basis,$lattice,$num_atoms,$total_atoms,$selectiveflag,$selective,$description)
    = read_poscar($inputfilename);
#    $basis=rotate_basis($basis);  # this ensures that there is a smooth conversion back from con format 

    set_bc($coordinates,$total_atoms);

    $coordinates = dirkar($coordinates,$basis,$lattice,$total_atoms);

    if(@args >= 2) {
        $outputfilename = $args[1];
    } else {
        $outputfilename = $inputfilename.".con";
    }
    open (OUT,">$outputfilename");
    print OUT "10000 RANDOM NUMBER SEED\n";
    print OUT "0.0000 TIME\n";

    for($j=0; $j<3; $j++) {
        $vector1->[0][$j] = $basis->[$j][0];
        $vector2->[0][$j] = $basis->[$j][1];
        $vector3->[0][$j] = $basis->[$j][2];
    }
    $mag1 = magnitude($vector1,1);
    $mag2 = magnitude($vector2,1);
    $mag3 = magnitude($vector3,1);
    printf OUT "%16.10f %16.10f %16.10f\n",$mag1,$mag2,$mag3;
	
    $angle1 = acos(dot_product($vector1,$vector2,1)/$mag1/$mag2)*$fact;
    $angle2 = acos(dot_product($vector1,$vector3,1)/$mag1/$mag3)*$fact;
    $angle3 = acos(dot_product($vector2,$vector3,1)/$mag3/$mag2)*$fact;
    printf OUT "%16.10f %16.10f %16.10f\n",$angle1,$angle2,$angle3;

    print OUT "0 0\n";
    printf OUT "0 0 0\n";
    $temp = @{$num_atoms};

    print "Number of types of atoms: $temp\n";

    printf OUT "%3i\n",$temp;
    for ($i=0; $i<@{$num_atoms}; $i++) {
        printf OUT "%3i ",$num_atoms->[$i];
    }
    print OUT "\n";
    for ($i=0; $i<@{$num_atoms}; $i++) {
        printf OUT "%3.1f ",1;
    }
    print OUT "\n";

    $prev = 0;
#    print OUT "From pos2con.pl\n";
    @description = split(/\s+/,$description);
    if(@description[0]) {
        print OUT "@description[0]\n";
    } else {
        print OUT "Type0\n";
    }
    for($i=0; $i<@{$num_atoms}; $i++) {
        print OUT "Coordinates of Component ".($i+1)."\n";
        print "Writing component ".($i+1)."\n";
        for($j=0; $j<$num_atoms->[$i]; $j++) {
            for($k=0; $k<3; $k++) {
                printf OUT "%17.14f ",$coordinates->[$j+$prev][$k];
            }
            if($selectiveflag =~ /^s/i) {
                if($selective->[$j+$prev] =~ /f/i) {
#GH: this warning should only be printed if one or two flags is t,
#    if all are false (the atom is frozen) then no data is lost
#          print "Possible data loss at atom number ";
#          print $j+1;
#          print " (atom has been fixed in all dimensions)\n";
                    print OUT " 1 ";
                } else {
                    print OUT " 0 ";
                }
            } else {
                print OUT " 0 ";
            }
            print OUT ($j+$prev+1)."\n";
        }
        if ($i != @{$num_atoms}-1) {
#        print OUT "Comp ".($i+1)." done\n";
            if(@description[$i+1]) {
                print OUT "@description[$i+1]\n";
            } else {
                print OUT "Type".($i+1)."\n";
            }
        } else {
            print OUT "\n";
        }
        $prev += $num_atoms->[$i];
    }
}

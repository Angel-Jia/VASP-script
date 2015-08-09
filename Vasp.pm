# VTSTSCRIPTS version V2.04 (07/07/11)
# v2.1 by sky, adjust write_poscar function to put out cartesian coordination
# v2.2 by sky, add a function to convert direct into cartesian
#I can't promise correct result if $lattice!=1.0

package Vasp;
use strict;
use Math::Trig;

BEGIN {
    use Exporter();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

    $VERSION = 1.00;

    @ISA = qw(Exporter);
#add
    @EXPORT = qw(&read_poscar &write_poscar &write_carposcar &rotate_basis &read_othercar &write_othercar &dot_product 
                 &magnitude &pbc_difference &vsum &vmult &dirkar &kardir &volume &inverse
                 &set_bc &bbc &pbc &gauss &unit);
   @EXPORT_OK = qw();
}

use vars @EXPORT_OK;
#add
use vars qw($coordinationflag);

#----------------------------------------------------------------------
# subroutine read_poscar
#     This routine reads in a POSCAR file.
#
#     INPUT: $filename: name of POSCAR file to read
#
#     OUTPUT: $coordinates: reference to Nx3 array of coordinates of
#                           POSCAR
#             $basis: reference to 3x3 array of basis vectors
#             $lattice: lattice constant of POSCAR
#             $num_atoms: reference to Mx1 array of number atoms/component
#             $total_atoms: N
#             $selectiveflag: is selective dynamics turned on?
#             $selective: flags for selective dynamics for each atom 
#                         (reference to Nx1 array)
#    add:coordinationflag: direct or cartesian
#----------------------------------------------------------------------

sub read_poscar {
    my $filename = shift;
    my $description = "";
    my @poscar = ();
    my $lattice = 0;
    my $basis;
    my $num_atoms;
    my $total_atoms = 0;
    my $coordinates;
    my $selectiveflag = "";
    my $atomtypeflag = "";
    my $selective;
    my $filetype;
    my $num_atoms_ = "";
    my @num_atoms = ();
    my $line = "";
    my @line = ();
    my $i = 0;
    my $j = 0;
    my $index;
    my $coords_kar;

    open (IN,$filename) or die "In vasp.pm::read_poscar, cannot open $filename\n";
    @poscar = <IN>;
    close (IN);

    chop($description = $poscar[0]);
    chop($lattice = $poscar[1]);

    $line = $poscar[5];
    $line =~ s/^\s+//;
    @line = split(/\s+/,$line);
#   if ($line =~ /^s/i) {
    if ($line[0] =~ /^\d+$/) {
        $filetype = "vasp4";
        $index = 5;
    } else {
        $filetype = "vasp5";
        $atomtypeflag = 1;
        chop($description = $poscar[5]);
        $index = 6;
    }
    $description =~ s/^\s+//;

    $num_atoms_ = $poscar[$index];
    $num_atoms_ =~ s/^\s+//;
    @num_atoms = split(/\s+/,$num_atoms_);
    for ($i=0; $i<@num_atoms; $i++) {
        $num_atoms->[$i] = $num_atoms[$i];
        $total_atoms += $num_atoms[$i];
    }

    for ($i=0; $i<3; $i++) {
        $line = $poscar[$i+2];
        $line =~ s/^\s+//;
        @line = split(/\s+/,$line);
        # This is how Vasp reads in the basis
        for ($j=0; $j<3; $j++) {
            $basis->[$j][$i] = $line[$j]*$lattice;
        }
    }
    $index += 1;

    $line = $poscar[$index];
    $line =~ s/^\s+//;
    if ($line =~ /^s/i) {
        chop($selectiveflag = $line);
        $index += 2;
    } else { $index += 1; }

    for ($i=$index; $i<$index+$total_atoms; $i++) {
        $poscar[$i] =~ s/^\s+//;
        @line = split(/\s+/,$poscar[$i]);
        for ($j=0; $j<3; $j++) {
            $coordinates->[$i-$index][$j] = $line[$j]; }
        if ($selectiveflag=~/^s/i) {
            $selective->[$i-$index] = $line[3]." ".$line[4]." ".$line[5];
        } else {
            $selective->[$i-$index] = " "; }
    }

    if ($poscar[$index-1] =~ /^c/i) {
        for ($i=0; $i<$total_atoms; $i++) {
            for ($j=0; $j<3; $j++) {
                $coordinates->[$i][$j] *= $lattice;
            }
        }
        $coordinates = kardir($coordinates,$basis,$lattice,$total_atoms);
    }

#add
    chop($coordinationflag = $poscar[$index-1]);
    #$basis=rotate_basis($basis);  # this ensures that there is a smooth conversion back from con format
    return($coordinates,$basis,$lattice,$num_atoms,$total_atoms,$selectiveflag,$selective,$description,$filetype,$coordinationflag);
}

#----------------------------------------------------------------------
# subroutine write_poscar
#     This routine writes out the POSCAR file in direct coordinates
#       
#     INPUT: $coordinates:  reference to Nx3 array
#            $basis: reference to 3x3 array containing basis vectors
#            $lattice:  lattice constant of POSCAR
#            $num_atoms: reference to Mx1 array containing number of
#                        each component of atoms
#            $total_atoms: N
#            $selectiveflag: flag saying if selective dynamics were
#                            used for this POSCAR
#            $selective: reference to Nx1 array containing selective
#                        dynamics flags for each atom
#
#     OUTPUT: none
#----------------------------------------------------------------------

sub write_poscar {
    my $coordinates = shift;
    my $basis = shift;
    my $lattice = shift;
    my $num_atoms = shift;
    my $total_atoms = shift;
    my $selectiveflag = shift;
    my $selective = shift;
    my $description = shift;
    my $filename = shift;
    my $filetype = shift;
    my $i = 0;
    my $j = 0;
    my $coord;

    open (OUT,">$filename") or die "In vasp.pm::write_poscar, cannot open $filename\n";
    print OUT $description."\n";
    print OUT $lattice."\n";
    for ($i=0; $i<3; $i++) {
        for ($j=0; $j<3; $j++) {
            printf OUT "%21.16f", ($basis->[$j][$i]/$lattice)." ";
        }
        print OUT "\n";
    }
    # this right now sets default as vasp5 file type 
    #if ($filetype eq "vasp5") {
    if ($filetype ne "vasp4") {
        print OUT $description."\n";
    }
    for ($i=0; $i<@{$num_atoms}; $i++) {
        print OUT $num_atoms->[$i]."  ";
    }
    print OUT "\n";

    if ($selectiveflag =~ /^s/i) { 
        print OUT $selectiveflag."\n";
    }
#add
    if ($coordinationflag =~ /^c/i){
        print OUT "Cartesian\n";   
        for ($i=0; $i<$total_atoms; $i++) {
            for ($j=0; $j<3; $j++) {
                $coord->[$i][$j] = $coordinates->[$i][$j];
                if ($coord->[$i][$j]>1) { $coord->[$i][$j] -= 1; }
                elsif ($coord->[$i][$j]<0) { $coord->[$i][$j] += 1; }
            }
        }
        $coord = dirkar($coord,$basis,$lattice,$total_atoms);
        for ($i=0; $i<$total_atoms; $i++) {
            for ($j=0; $j<3; $j++) {
                printf OUT "%20.16f", $coord->[$i][$j]."   ";
            }
            print OUT " ".$selective->[$i]."\n";
        }
    }else{
        print OUT "Direct\n";
        for ($i=0; $i<$total_atoms; $i++) {
            for ($j=0; $j<3; $j++) {
                $coord = $coordinates->[$i][$j];
                if ($coord>1) { $coord -= 1; }
                elsif ($coord<0) { $coord += 1; }
                printf OUT "%20.16f", $coord."   "; 
            }
            print OUT " ".$selective->[$i]."\n";
        }
    }
    close (OUT);
    return();
}

#----------------------------------------------------------------------
# subroutine write_carposcar
# the same as write_carposcar except outputing cartesian
#----------------------------------------------------------------------

sub write_carposcar {
    my $coordinates = shift;
    my $basis = shift;
    my $lattice = shift;
    my $num_atoms = shift;
    my $total_atoms = shift;
    my $selectiveflag = shift;
    my $selective = shift;
    my $description = shift;
    my $filename = shift;
    my $filetype = shift;
    my $i = 0;
    my $j = 0;
    my $coord;

    open (OUT,">$filename") or die "In vasp.pm::write_poscar, cannot open $filename\n";
    print OUT $description."\n";
    print OUT $lattice."\n";
    for ($i=0; $i<3; $i++) {
        for ($j=0; $j<3; $j++) {
            printf OUT "%21.16f", ($basis->[$j][$i]/$lattice)." ";
        }
        print OUT "\n";
    }
    # this right now sets default as vasp5 file type 
    #if ($filetype eq "vasp5") {
    if ($filetype ne "vasp4") {
        print OUT $description."\n";
    }
    for ($i=0; $i<@{$num_atoms}; $i++) {
        print OUT $num_atoms->[$i]."  ";
    }
    print OUT "\n";

    if ($selectiveflag =~ /selective/i) { 
        print OUT $selectiveflag."\n";
    }

    print OUT "Cartesian\n";
    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $coord->[$i][$j] = $coordinates->[$i][$j];
            if ($coord->[$i][$j]>1) { $coord->[$i][$j] -= 1; }
            elsif ($coord->[$i][$j]<0) { $coord->[$i][$j] += 1; }
        }
    }
    $coord = dirkar($coord,$basis,$lattice,$total_atoms);
    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            printf OUT "%20.16f", $coord->[$i][$j]."   ";
        }
        print OUT " ".$selective->[$i]."\n";
    }
    close (OUT);
    return();
}


#----------------------------------------------------------------------
# subroutine rotate_basis
#     subroutine that rotates basis vectors so that v1->xdir and v2->xy plane
#       this is important for smooth conversions between con and POSCAR formats 
#     INPUT: $basis: reference to 3x3 array containing basis vectors
#
#     OUTPUT: $basis
#----------------------------------------------------------------------
sub rotate_basis {
    my $basis = shift;
    my $a;
    my $b;
    my $angle;
    my $i = 0;
    if ($basis->[1][0] != 0.) { # rotate around Z
        $angle = acos($basis->[0][0]/sqrt($basis->[0][0]**2+$basis->[1][0]**2));
        if ($basis->[1][0]<0) { $angle *= -1; }
        #print "angle ",$angle,"\n";
        for ($i=0; $i<3; $i++) {
            $a = $basis->[0][$i];
            $b = $basis->[1][$i];
            $basis->[0][$i] = $a*cos($angle) + $b*sin($angle);
            $basis->[1][$i] = -$a*sin($angle) + $b*cos($angle);
        }
    }
    if ($basis->[2][0] != 0.) {  # rotate around Y
        $angle = acos($basis->[0][0]/sqrt($basis->[0][0]**2 + $basis->[2][0]**2));
        if ($basis->[2][0]<0) { $angle *= -1; }
        #print "angle ",$angle,"\n";
        for ($i=0; $i<3; $i++) {
            $a = $basis->[0][$i];
            $b = $basis->[2][$i];
            $basis->[0][$i] = $a*cos($angle) + $b*sin($angle);
            $basis->[2][$i] = -$a*sin($angle) + $b*cos($angle);
        }
    }
    if ($basis->[2][1] != 0.) { # rotate around X
        $angle = acos($basis->[1][1]/sqrt($basis->[1][1]**2 + $basis->[2][1]**2));
        if ($basis->[2][1]<0) { $angle *= -1; }
        #print "angle ",$angle,"\n";
        for ($i=0; $i<3; $i++) {
            $a = $basis->[1][$i];
            $b = $basis->[2][$i];
            $basis->[1][$i] = $a*cos($angle)+$b*sin($angle);
            $basis->[2][$i] = -$a*sin($angle)+$b*cos($angle);
        }
    }
    $basis->[1][0] = 0; # No need to carry floating point errors 
    $basis->[2][0] = 0;
    $basis->[2][1] = 0;
    return($basis);
}  
#----------------------------------------------------------------------
# subroutine read_othercar
#     This routine reads files that are just an Nx3 array of numbers
#     (like INTERCAR and NORMCAR, for example).
#
#     INPUT: $filename: name of file to read
#
#     OUTPUT: $coordinates:  reference to Nx3 array
#             $total_atoms:  N
#----------------------------------------------------------------------

sub read_othercar {
    my $filename = shift;
    my @othercar = ();
    my $total_atoms = 0;
    my $coordinates;
    my $line = "";
    my @line = ();
    my $i = 0;
    my $j = 0;

    open (IN,$filename) or die "In vasp.pm::read_othercar, cannot open $filename\n";
    while ($line = <IN>) {
        $line =~ s/^\s+//g;
        @line = split(/\s+/,$line);
        # check to see if the first entry is a number
#       if($line[0] =~ /^\d+\.*\d*$/){
        if($line[0] =~ /^[-+]?\d+(\.\d+)?([eE][-+]?\d+)?$/) {
            for ($j=0; $j<3; $j++) {
                $coordinates->[$i][$j] = $line[$j];
            }
            $i++;
        }
    }
    close (IN);
    $total_atoms = $i;

    return($coordinates,$total_atoms);
}

#----------------------------------------------------------------------
# subroutine write_othercar
#     This routine writes an Nx3 array of numbers to a file
#     (like INTERCAR and NORMCAR, for example).
#
#     INPUT: $coordinates:  reference to Nx3 array
#             $total_atoms:  N
#----------------------------------------------------------------------

sub write_othercar{
    my $coordinates = shift;
    my $total_atoms = shift;
    my $filename = shift;
    my ($i,$j,$coord);
    open (OUT,">$filename") || die "In Vasp.pm::write_othercar : cannot open $filename\n";
    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $coord = $coordinates->[$i][$j];
            printf OUT "%20.16f", $coord."   ";
        }
        print OUT "\n";
    }
    close (OUT);
}

#----------------------------------------------------------------------
# subroutine dot_product
#     This routine does a dot product between two arrays.
#
#     INPUT: $coordinates1: reference to Nx3 array
#            $coordinates2: reference to Nx3 array
#            $total_atoms: N
#
#     OUTPUT: $mag: dot product between $coordinates1 and $coordinates2
#----------------------------------------------------------------------

sub dot_product {
    my $coordinates1 = shift;
    my $coordinates2 = shift;
    my $total_atoms = shift;

    my ($i,$j);
    my $mag = 0;

    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $mag += $coordinates1->[$i][$j]*$coordinates2->[$i][$j];
        }
    }
    return ($mag);
}

#----------------------------------------------------------------------
# subroutine magnitude
#     This routine calculates the magnitude of a vector
#
#     INPUT: $coordinates: reference to Nx3 array
#            $total_atoms: N
#
#     OUTPUT: $mag: magnitude of $coordinates
#----------------------------------------------------------------------

sub magnitude {
    my $coordinates = shift;
    my $total_atoms = shift;

    my ($i,$j);
    my $mag = 0;

    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $mag += $coordinates->[$i][$j]**2;
        }
    }
    $mag = sqrt($mag);
    return ($mag);
}

#----------------------------------------------------------------------
# subroutine pbc_difference
#     This routine does a difference between two vectors and applies
#     periodic boundary conditions to the difference.
#
#     INPUT: $coordinates1: reference to Nx3 array
#            $coordinates2: reference to Nx3 array
#            $total_atoms: N
#
#     OUTPUT: $difference: difference between $coordinates1 and $coordinates2
#----------------------------------------------------------------------

sub pbc_difference {
    my $coordinates1 = shift;
    my $coordinates2 = shift;
    my $total_atoms = shift;

    my $i = 0;
    my $j = 0;
    my $difference;

    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $difference->[$i][$j] = pbc($coordinates1->[$i][$j] - $coordinates2->[$i][$j]);
        }
    }
    return ($difference);
}

#----------------------------------------------------------------------
# subroutine unit
#     This routine returns the unit vector of the given vector
#
#     INPUT: $coordinates: reference to Nx3 array
#            $total_atoms: N
#
#     OUTPUT: $unitv: unit vector of $coordinates
#----------------------------------------------------------------------

sub unit
{
    my $coordinates = shift;
    my $total_atoms = shift;

    my $i = 0;
    my $j = 0;
    my $unitv;
    my $sum = 0;

    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $sum += $coordinates->[$i][$j] * $coordinates->[$i][$j];
            $unitv->[$i][$j] = $coordinates->[$i][$j];
        }
    }
    my $mag = sqrt($sum);
    for ($i=0; $i<$total_atoms; $i++) 
    {
        for ($j=0; $j<3; $j++) 
        {
            $unitv->[$i][$j] = $unitv->[$i][$j] / $mag;
        }
    }
    return ($unitv);
}

#----------------------------------------------------------------------
# subroutine vsum
#     This routine adds two vectors
#
#     INPUT: $v1: reference to array containing coordinates (Nx3)
#            $v2: reference to array containing coordinates (Nx3)
#            $total_atoms: N
#
#     OUTPUT: $vector:  summed vectors
#----------------------------------------------------------------------

sub vsum {
    my $v1 = shift;
    my $v2 = shift;
    my $total_atoms = shift;
 
    my ($i,$j,$vector);
    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $vector->[$i][$j] = $v1->[$i][$j] + $v2->[$i][$j];
        }
    }
    return ($vector);
}

#----------------------------------------------------------------------
# subroutine vmult
#     This routine multiplies a number with a vector
#
#     INPUT: $v: reference to array containing coordinates (Nx3)
#            $fact: multiplication factor
#            $total_atoms: N
#
#     OUTPUT: $vector:  summed vectors
#----------------------------------------------------------------------

sub vmult {
    my $v = shift;
    my $fact = shift;
    my $total_atoms = shift;

    my ($i,$j,$vector);
    for ($i=0; $i<$total_atoms; $i++) {
        for ($j=0; $j<3; $j++) {
            $vector->[$i][$j] = $v->[$i][$j]*$fact;
        }
    }
    return ($vector);
}
#----------------------------------------------------------------------
# subroutine dirkar
#     This routine converts coordinates from direct lattice to 
#     cartesian.  NOTE:  OUTPUT is in full cartesian, not scaled
#     cartesian.
#
#     INPUT: $vector: reference to array containing coordinates (Nx3)
#            $basis: reference to 3x3 array containing basis
#            $lattice:  lattice constant of coordinates
#            $total_atoms: N
#
#     OUTPUT: $vector:  converted coordinates
#----------------------------------------------------------------------

sub dirkar {
    my $vector = shift;
    my $basis = shift;
    my $lattice = shift;
    my $total_atoms = shift;

    my ($i,$v1,$v2,$v3);

    for ($i=0; $i<$total_atoms; $i++) {
        $v1 = $vector->[$i][0]*$basis->[0][0] + $vector->[$i][1]*$basis->[0][1] + $vector->[$i][2]*$basis->[0][2];
        $v2 = $vector->[$i][0]*$basis->[1][0] + $vector->[$i][1]*$basis->[1][1] + $vector->[$i][2]*$basis->[1][2];
        $v3 = $vector->[$i][0]*$basis->[2][0] + $vector->[$i][1]*$basis->[2][1] + $vector->[$i][2]*$basis->[2][2];
        $vector->[$i][0] = $v1;
        $vector->[$i][1] = $v2;
        $vector->[$i][2] = $v3;
    }

    return ($vector);
}

#----------------------------------------------------------------------
# subroutine kardir
#     This routine converts coordinates from cartesian to 
#     direct lattice.  NOTE:  INPUT should be in full cartesian, not
#     scaled cartesian, coordinates.
#
#     INPUT: $vector: reference to array containing coordinates (Nx3)
#            $basis: reference to 3x3 array containing basis
#            $lattice:  lattice constant of coordinates
#            $total_atoms: N
#
#     OUTPUT: $vector:  converted coordinates
#----------------------------------------------------------------------

sub kardir {
    my $vector = shift;
    my $basis = shift;
    my $lattice = shift;
    my $total_atoms = shift;
    my $recip_basis;
    my ($v1,$v2,$v3,$i,$j);
  
    $recip_basis = inverse($basis);
  
    for ($i=0; $i<$total_atoms; $i++) {
        $v1 = $vector->[$i][0]*$recip_basis->[0][0] + $vector->[$i][1]*$recip_basis->[1][0] + $vector->[$i][2]*$recip_basis->[2][0];
        $v2 = $vector->[$i][0]*$recip_basis->[0][1] + $vector->[$i][1]*$recip_basis->[1][1] + $vector->[$i][2]*$recip_basis->[2][1];
        $v3 = $vector->[$i][0]*$recip_basis->[0][2] + $vector->[$i][1]*$recip_basis->[1][2] + $vector->[$i][2]*$recip_basis->[2][2];

        # move atoms to primative cell
        $vector->[$i][0] = $v1+60-int($v1+60);
        $vector->[$i][1] = $v2+60-int($v2+60);
        $vector->[$i][2] = $v3+60-int($v3+60);
    }
    for ($i=0;$i<3;$i++) {
        for ($j=0;$j<3;$j++) {
            # print $basis->[$i][$j]." ";
        }
        # print " .... ";
        for ($j=0;$j<3;$j++) {
            #  print $recip_basis->[$i][$j]." ";
        }
        # print "\n";
    }
    return ($vector);
}

#----------------------------------------------------------------------
# subroutine volume
#     This subroutine returns the volume of the basis
#
#     INPUT: $basis:  reference to 3x3 basis array
#
#     OUTPUT: $volume: volume of basis vectors
#----------------------------------------------------------------------

sub volume {
    my $basis = shift;

    my $volume;

    $volume =
        $basis->[0][0]*($basis->[1][1]*$basis->[2][2] - $basis->[1][2]*$basis->[2][1]) -
        $basis->[0][1]*($basis->[1][0]*$basis->[2][2] - $basis->[2][0]*$basis->[1][2]) +
        $basis->[0][2]*($basis->[1][0]*$basis->[2][1] - $basis->[2][0]*$basis->[1][1]);

    return($volume)
}

#----------------------------------------------------------------------
# subroutine inverse
#     This subroutine inverts the basis, so that a conversion from
#     cartesian to direct coordinates can be done.
#
#     INPUT: $basis:  reference to 3x3 basis array
#
#     OUTPUT: $inverse: reference to 3x3 inverse of basis
#----------------------------------------------------------------------

sub inverse {
    my $basis = shift;

    my $inverse;

    my $omega = 0;
    my ($i,$ii,$iii,$j,$jj,$jjj);

    for ($i=0; $i<3; $i++) {
        $ii = $i+1;
        if ($ii>2) { $ii-=3; }
        $iii = $ii+1;
        if ($iii>2) { $iii-=3; }
        for ($j=0;$j<3;$j++) {
            $jj = $j+1;
            if ($jj>2) { $jj-=3; }
            $jjj = $jj + 1;
            if ($jjj>2) { $jjj-=3; }
            $inverse->[$j][$i] = $basis->[$jj][$ii]*$basis->[$jjj][$iii] - $basis->[$jjj][$ii]*$basis->[$jj][$iii];
            # print "$i $ii $iii $j $jj $jjj: ".$inverse->[$j][$i]."\n";
        }
    }

    $omega = $inverse->[0][0]*$basis->[0][0] + $inverse->[1][0]*$basis->[1][0] + $inverse->[2][0]*$basis->[2][0];

    for ($i=0; $i<3; $i++) {
        for ($j=0; $j<3; $j++) {
            $inverse->[$i][$j] /= $omega;
        }
    }

    return($inverse);
}

#----------------------------------------------------------------------
# subroutine set_bc
#     This routine applies boundary conditions (bc)
#
#     INPUT: $coordinates: coordinate to apply bc to, in direct lattice
#            $total_atoms: total number of atoms
#
#     OUTPUT: $coordinates:  coordinate with bc applied
#----------------------------------------------------------------------

sub set_bc {
    my $coordinates = shift;
    my $total_atoms = shift;

    my($i,$j);
 
    # Boundaries [0,1]
    if($ENV{'VTST_BC'} eq 'BBC') {
        for($i=0; $i<$total_atoms; $i++){
            for($j=0; $j<3; $j++){
                $coordinates->[$i][$j] = bbc($coordinates->[$i][$j]); }}
    # Boundaries [-0.5,0.5]
    } elsif($ENV{'VTST_BC'} eq 'PBC') {
        for($i=0; $i<$total_atoms; $i++){
            for($j=0; $j<3; $j++){
                $coordinates->[$i][$j] = pbc($coordinates->[$i][$j]); }}
    # Boundaries [1-x,x]
    } elsif($ENV{'VTST_BC'} eq 'CBC') {
        for($i=0; $i<$total_atoms; $i++){
            for($j=0; $j<3; $j++){
                $coordinates->[$i][$j] = cbc($coordinates->[$i][$j]); }}
    }
}

#----------------------------------------------------------------------
# subroutine pbc
#     This routine applies periodic boundary conditions to a direct
#     lattice coordinate.
#
#     INPUT: $distance: coordinate to apply PBC to, in direct lattice
#
#     OUTPUT: $distance:  coordinate with PBC applied
#----------------------------------------------------------------------

sub pbc {
    my $distance = shift;

    #GH: this should be changed to a Wigner-Sitz algorithm 
    if ($distance <= -0.5) {
        $distance += 1.0;
    } elsif ($distance > 0.5) {
        $distance -= 1.0;
    }
    return($distance);
}

#----------------------------------------------------------------------
# subroutine bbc
#     This routine applies box boundary conditions to a direct
#     lattice coordinate.
#
#     INPUT: $distance: coordinate to apply BBC to, in direct lattice
#
#     OUTPUT: $distance:  coordinate with BBC applied
#----------------------------------------------------------------------

sub bbc {
    my $distance=shift;

    while($distance <= 0.0) {
        $distance += 1.0; }
    while($distance > 1.0) {
        $distance -= 1.0; }
    return($distance);
}

#----------------------------------------------------------------------
# subroutine gauss
#     This routine generates a Gaussian distributed random number
#     Algorithm from Numeric Recipes (mean 0, width 1)
#
#     OUTPUT: $gset:  Gaussian distributed random number
#----------------------------------------------------------------------
{ 
    my $gset;
    my $iset = 0;

    srand();

    sub gauss { 
        my ($v1,$v2,$rsq,$fac);
        if ($iset == 0){
            do{ 
                $v1 = 2.0*rand() - 1.0;
                $v2 = 2.0*rand() - 1.0;
                $rsq = $v1*$v1 + $v2*$v2;
            } while ($rsq >= 1.0 || $rsq == 0.0);
            $fac = sqrt(-2.0*log($rsq)/$rsq);
            $gset = $v1*$fac;
            $iset = 1;
            return $v2*$fac;
        } else {
            $iset = 0;
            return $gset;
        }
    }
}

1;

#!/usr/bin/env perl
#;-*- Perl -*-

# Created by dano 5-28-08
# LAST MODIFIED by dano: 4-29-10
# convert chgcar and locpot to cube format
##################################################
# 4-29: fixed RHO reading issuse
# 4-28: fix output units, reduced memory needed 
# 2-16: Setup to read also vasp5 format
# 2-16: Fixed error optional 1st comment line
# 12-29: checked for non-ortho box
# 8-22: fixed units for chgcar conversion 
# 8-13: del vars when done with them 
##################################################

use FindBin qw($Bin);
use lib "$Bin";
#use Vasp;
use Math::Trig;
$fact = 180/pi;

print "\n";
@args = @ARGV;
@args >= 1 || die "usage: chg2cube.pl <CHGCAR or LOCPOT or PARCHG file>\n";
$inputfilename = $args[0];

# prompt USER for file format
print "SELECT INPUT FILE FORMAT 1=CHGCAR or 2=LOCPOT 3=PARCHG:  ";
chomp($filetype_ = <STDIN>);
#$filetype_ = 1;
if ($filetype_ == 1) {$filetype = "chgcar";}
if ($filetype_ == 2) {$filetype = "locpot";}
if ($filetype_ == 3) {$filetype = "parchg";}
if ($filetype_ == 1 or $filetype_ == 2 or $filetype_ == 3) {
    print "     READING '$filetype' FILE FORMAT\n";
    print "\n";
}else{
    die "     YOU MUST ENTER 1 or 2 or # FOR FILE FORMAT\n";
}

## bohr or ang (uncomment for selection)
#print "SELECT UNITS FOR OUTPUT 1=BOHR/HARTREE or 2=ANGSTROMS/eV:  ";
#chomp($units = <STDIN>);
#if ($units == 1) {$unittype= "bohr/hartree"; $l_units=1.889725992; $e_units=0.036749309; $unit_flag=-1;} # Ang ----> Bohr
#if ($units == 2) {$unittype= "angstroms/eV"; $l_units=1.0; $e_units=1; $unit_flag=1} # Ang ----> Ang 
#if ($units == 1 or $units == 2) {
#  print "     USING '$unittype' FOR OUTPUT UNITS\n";
#  print "\n";}
#else {die "    YOU MUST ENTER 1 or 2 FOR UNITS\n";}

# Assume atomic units 
$unittype = "bohr/hartree";
$l_units = 1.889725992;
$e_units = 0.036749309;
$unit_flag = 1;
print "     USING '$unittype' FOR OUTPUT UNITS\n";

# prompt USER for ATOMIC NUMBERS of ELEMENTs in file 
print "ENTER ELEMENT TYPES BY ATOMIC NUMBER:  ";
#$atom_types_=@_;
#$atom_types_ = <STDIN>
chomp($atom_types_ = <STDIN>);
print "\n";
$atom_types_ =~ s/^\s+//;
@atom_types = split(/\s+/,$atom_types_);
#@atom_types=(3,8,15,26);
for ($i=0; $i<@atom_types; $i++) {
    $atom_types->[$i] = $atom_types[$i];
}

$inputfile = "";
open (IN,$inputfilename);
while (<IN>) {
    $_ =~ s/^\s+//g;
    $inputfile .= $_;
}
close (IN);

@inputfile = split(/\n/,$inputfile);

# check for a comment line
$line = $inputfile[0] ;
$line =~ s/^\s+//;
@line = split(/\s+/,$line);
if ($line[0] =~ /^\d+(\.\d+)?/) {
    $index = 0;
} else {
    chop($description = $inputfile[0]);
    $index = 1;
}
$lattice = $inputfile[$index];

#Check for vasp5 format
$line = $inputfile[$index+4] ;
$line =~ s/^\s+//;
@line = split(/\s+/,$line);
#  if ($line=~/^s/i) {
if ($line[0] =~ /^\d+$/) {
    $vasp5 = 0;
}else{
    chop($description = $inputfile[$index+4]);
    $vasp5 = 1;
}

# read total atoms
$num_atoms_ = $inputfile[$index+4+$vasp5];
#print $num_atoms;
$num_atoms_ =~ s/^\s+//;
@num_atoms = split(/\s+/,$num_atoms_);
#print @num_atoms;
for ($i=0; $i<@num_atoms; $i++) {
    $num_atoms->[$i] = $num_atoms[$i];
    $total_atoms += $num_atoms->[$i];
}

# make sure you have as many types of elements as atomic numbers entered
#print "@num_atoms\n";
#print "@atom_types\n";
if (@num_atoms!=@atom_types) {die "    NUMBER OF ELEMENT TYPES DOES NOT MATCH NUMBER OF ATOMIC NUMBERS GIVEN\n";}

for ($i=0; $i<3; $i++) {
    $line_ = $inputfile[$i+$index+1];
    $line_ =~ s/^\s+//;
    @line = split(/\s+/,$line_);
    # This is how Vasp reads in the basis
    for ($j=0; $j<@line; $j++) {
        $basis->[$j][$i] = $line[$j]*$lattice*$l_units;
    }
}

# correct volume for non-orthognal box (expansion by minors)
$vol = $basis->[0][0]*($basis->[1][1]*$basis->[2][2] - $basis->[2][1]*$basis->[1][2])
     - $basis->[1][0]*($basis->[0][1]*$basis->[2][2] - $basis->[2][1]*$basis->[0][2])
     + $basis->[2][0]*($basis->[0][1]*$basis->[1][2] - $basis->[1][1]*$basis->[0][3]);

# make sure volume is +
# this volume is in units selected (default bohr) but we need it in ang**3
$vol = abs($vol)/($l_units**3);
#print "$vol\n";

# read in coordinates
$index = $index + $vasp5 + 6;
#print "$index\n";
for ($i=$index; $i<$index+$total_atoms; $i++) {
    $line_ = $inputfile[$i];
    $line_ =~ s/^\s+//;
    @line = split(/\s+/,$line_);
    for ($j=0; $j<@line; $j++) {
        $coordinates->[$i-$index][$j] = $line[$j];
    }
}

# change coordinates to cartesian
for ($i=0; $i<$total_atoms; $i++) {
    $v1 = $coordinates->[$i][0]*$basis->[0][0] + $coordinates->[$i][1]*$basis->[0][1] + $coordinates->[$i][2]*$basis->[0][2];
    $v2 = $coordinates->[$i][0]*$basis->[1][0] + $coordinates->[$i][1]*$basis->[1][1] + $coordinates->[$i][2]*$basis->[1][2];
    $v3 = $coordinates->[$i][0]*$basis->[2][0] + $coordinates->[$i][1]*$basis->[2][1] + $coordinates->[$i][2]*$basis->[2][2];

    $coordinates->[$i][0] = $v1;
    $coordinates->[$i][1] = $v2;
    $coordinates->[$i][2] = $v3;
}

# read number of grid-points
$index = $index + $total_atoms;
$fft_grid_ = $inputfile[$index];
$fft_grid_ =~ s/^\s+//;
@fft_grid = split(/\s+/,$fft_grid_);
$grid_points = 1;
for ($i=0; $i<@fft_grid; $i++) {
    $fft_grid->[$i] = $fft_grid[$i];
    $grid_points *= $fft_grid->[$i];
}

$nx = $fft_grid->[0];
$ny = $fft_grid->[1];
$nz = $fft_grid->[2];
print "gridpoints $grid_points\n";
$data_lines = int($grid_points/5+1);
if ($filetype_ == 3) {
    $data_lines = int($grid_points/10);
}
#print "$data_lines\n";

####READ IN THE RHO DATA####
$index += 1;
$ii = 0;
#print $index;
for ($i=$index; $i<($index+$data_lines); $i++) {
    $line_ = $inputfile[$i];
    $line_ =~ s/^\s+//;
    @line = split(/\s+/,$line_);
    for ($j=0; $j<@line; $j++) {
        # density is read in x-inner,y-middle,z-outer loop
        $density->[$ii] = $line[$j];
        $ii++;
    }
}
print "gridpoints read $ii \n";
print "$density->[$ii-1]\n";
  
#print "$density->[0]\n";
#print "$density->[1]\n";
#print "$density->[2]\n";
#print "$density->[3]\n";

# del inputfile
undef @inputfile;
undef $inputfile;

##############################################
###### WRITE OUT THE CUBE FILE ###############
##############################################
if(@args >= 2) { $outputfilename = $args[1]; }
else { $outputfilename = $inputfilename.".cube"; }
open (OUT,">$outputfilename");
# printing garbage header
print OUT "CUBE FILE CONVERTED FROM VASP format\n";
print OUT "OUTTER LOOP: X, MIDDLE LOOP: Y, INNER LOOP: Z\n";
# Natoms center of volumetric data?   whatever that means
printf OUT "%5i %12.6f %12.6f %12.6f\n",$total_atoms,0,0,0 ;

# grid numbers box vectors 
# unit flag is negative for bohr
printf OUT "%5i %12.6f %12.6f %12.6f\n",$unit_flag*$nx,$basis->[0][0]/$nx,$basis->[1][0]/$nx,$basis->[2][0]/$nx;
printf OUT "%5i %12.6f %12.6f %12.6f\n",$ny,$basis->[0][1]/$ny,$basis->[1][1]/$ny,$basis->[2][1]/$ny;
printf OUT "%5i %12.6f %12.6f %12.6f\n",$nz,$basis->[0][2]/$nz,$basis->[1][2]/$nz,$basis->[2][2]/$nz;

# atomic number | ? | x y z in direct coordinates
$cum_num_atom_types->[0] = $num_atoms->[0];
for ($i=1; $i<@num_atoms; $i++){
    $cum_num_atom_types->[$i] = $cum_num_atom_types->[$i-1] + $num_atoms->[$i];
}

$j = 0;
for ($i=0; $i<$total_atoms; $i++) {
    if ($i<$cum_num_atom_types->[$j]) {
        printf OUT "%5i %12.6f %12.6f %12.6f %12.6f\n",$atom_types->[$j],0,$coordinates->[$i][0],$coordinates->[$i][1],$coordinates->[$i][2];
    }else{
        $j++;
        printf OUT "%5i %12.6f %12.6f %12.6f %12.6f\n",$atom_types->[$j],0,$coordinates->[$i][0],$coordinates->[$i][1],$coordinates->[$i][2];
    }
}

##### Write out the density ###########
# volume scaling for CHGCAR
if ($filetype_ == 1) { $vol_scale = 1.0/($vol); } # chgcar 
if ($filetype_ == 2) { $vol_scale = 1.0; } # locpot
if ($filetype_ == 3) { $vol_scale = 1.0/($vol); } # parchg

# density is read in x-inner,y-middle,z-outer loop
# needs to be written as z-inner,y-middle,x-outer loop
$ii=0;
for ($ix=0; $ix<$nx; $ix++) {
    for ($iy=0; $iy<$ny; $iy++) {
        for ($iz=0; $iz<$nz; $iz++) {
            $itr = ($iz*$nx*$ny) + ($iy*$nx) + $ix;
            printf OUT "%13.5E ",$vol_scale*$e_units*$density->[$itr];
            if ($ii%6 ==5) {
                print OUT " \n";
            }
            $ii++;
        }
    }
}

close (OUT);


##########################################


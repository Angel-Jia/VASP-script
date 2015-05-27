#!/usr/bin/env perl
#;-*- Perl -*-

# Open the XDATCAR. If no argument is supplied XDATCAR is open
# by default. If argument is supplied that file will be opened.

$zip = $ENV{'VTST_ZIP'};
if($zip eq '') { $zip = 'gzip'; }

if(@ARGV == undef){
    if(-e "XDATCAR") {
        $xdatzipped = 0;
    } elsif(-e "XDATCAR.gz") {
        print " XDATCAR IS ZIPPED, UNZIPPING \n";
        system "gunzip XDATCAR.gz";
        $xdatzipped = 1;
    } elsif(-e "XDATCAR.bz2") {
      print " XDATCAR IS ZIPPED, UNZIPPING \n";
      system "bunzip2 XDATCAR.bz2";
      $xdatzipped = 1;
    } else {
        die " NO XDATCAR IN THIS DIRECTORY \n";
    }
    print " OPEN XDATCAR ... \n";
    open XDAT, "XDATCAR"
      or die " ...  XDATCAR MISSING FROM THIS DIRECTORY \n";
} else {
    print " OPEN ",@ARGV[0]," ... \n";
    open XDAT, @ARGV[0]
      or die " ... ",@ARGV[0]," MISSING FROM THIS DIRECTORY \n";
}

# Get the forces and energies to print in the xyz-file

if(-e "OUTCAR") {
    $zipped = 0;
} elsif(-e "OUTCAR.gz") {
    print " OUTCAR IS ZIPPED, UNZIPPING \n";
    system "gunzip OUTCAR.gz";
    $zipped = 1;
} elsif(-e "OUTCAR.bz2") {
    print " OUTCAR IS ZIPPED, UNZIPPING \n";
    system "bunzip2 OUTCAR.bz2";
    $zipped = 1;
} else {
    die " NO OUTCAR IN THIS DIRECTORY \n";
}

$forces = `grep 'FORCES: max atom, RMS' OUTCAR`;
$energy = `grep 'energy  without entropy' OUTCAR`;
@forces = split /\n/, $forces;
@energy = split /\n/, $energy;
if($zipped) {
    print " ZIPPING OUTCAR AGAIN \n";
    system "$zip OUTCAR &";
}

# Get information about, number and types of atoms, box lengths ets.
# from the POSCAR file.


if(-e "XDATCAR") {
    open POS, "CONTCAR";
}else{
    open POS, "POSCAR" or die " NO POSCAR IN THIS DIRECTORY \n";
}
for($i=0; $i<=8; $i++) {
    $line = <POS>;
    chomp($line);
    $line =~ s/^\s+//g;
    @line = split /\s+/,$line;
    if($i == 0){
        @elements = split /\s+/, $line;
        $nel = @elements;
    }
    if($i == 1) { $latt = $line[0]; }
    if($i == 2) { @sidex[0..2] = @line[0..2]; }
    if($i == 3) { @sidey[0..2] = @line[0..2]; }
    if($i == 4) { @sidez[0..2] = @line[0..2]; }
    if($i == 5) {
        if($line[0] =~ /^\d+$/) {
            @not[0..$nel-1] = @line[0..$nel-1];
            # Calculate the number of atoms
            while($not[$k] != undef) {
                $natoms += $not[$k++];
            }
        } else {
            $atomtypeflag = 1; #check for vasp5 style POSCAR
            print "VASP 5 format\n";
            @elements = split /\s+/, $line;
            $nel = @elements;
        }
    }
    if($i == 6) {
        if($atomtypeflag == 1){
            @not[0..$nel-1] = @line[0..$nel-1];
            # Calculate the number of atoms
            while($not[$k] != undef) {
                $natoms += $not[$k++];
            }
        }
    }
}
close POS;

# Assign a type (element) to each atom.

$n = 0;
$j = 0;
for($i=1; $i<=$natoms; $i++) {
    $j++;
    if($j <= $not[$n]){
        $type[$i-1] = $elements[$n];
    } else {
        $n++;
        $type[$i-1] = $elements[$n];
        $j = 1;
    }
}

# Read the XDAT file and make .xyz files

if($atomtypeflag == 1) {
    # Jump over the first few line "vasp 5"
    for($i=0; $i<7; $i++){
        $line = <XDAT>;
    }
} else {
    # Jump over the first few lines old XDATCAR
    for($i=0; $i<5; $i++) {
        $line = <XDAT>;
    }
}

$n = 0;
open MOV, ">movie.xyz";
while($line = <XDAT>) {
    chomp($line);
    print MOV $natoms,"\n";
    $f = $forces[$n]; chomp($f); $f =~ s/^\s+//g; @f = split /\s+/,$f;
    $e = $energy[$n]; chomp($e); $e =~ s/^\s+//g; @e = split /\s+/,$e;
    print MOV "FORCE:  $f[4]  ...  ENERGY:  $e[6]","\n" ;
    for($i=0; $i<$natoms; $i++){
        $line = <XDAT>;
        chomp($line); $line =~ s/^\s+//g; @line = split /\s+/,$line;
        
        #  Transform from direct coordinates to cart. coordinates.
        $x = $line[0];
        $y = $line[1];
        $z = $line[2];
        #  Periodic boundaries
        # while($x<-0.5){$x+=1.0;} while($x>0.5){$x-=1.0;}
        # while($y<-0.5){$y+=1.0;} while($y>0.5){$y-=1.0;}
        # while($z<-0.5){$z+=1.0;} while($z>0.5){$z-=1.0;}
        $xt = $x*$sidex[0] + $y*$sidey[0] + $z*$sidez[0];
        $yt = $x*$sidex[1] + $y*$sidey[1] + $z*$sidez[1];
        $zt = $x*$sidex[2] + $y*$sidey[2] + $z*$sidez[2];
        $x = $latt*$xt;
        $y = $latt*$yt;
        $z = $latt*$zt;
        printf MOV "%2s %18.13f %18.13f %18.13f \n",$type[$i],$x,$y,$z;
    }
    $n++;
}
close XDAT;
if($xdatzipped) {
    print " ZIPPING XDATCAR AGAIN \n";
    system "$zip -9 XDATCAR &";
}

#!/usr/bin/env perl
#;-*- Perl -*-

use FindBin qw($Bin);
use lib "$Bin";
use Vasp;

open NEB , ">neb.dat" ;

@args = @ARGV;
if (@args==0) {
    opendir(DIR,".") or die "couldn't open . ($!)\n";
    @list = readdir(DIR);
    closedir(DIR);

    @directories = grep {-d && /^[0-9][0-9]$/i} @list;
    @directories = sort {$a<=>$b} @directories;
} else {
    @directories = @args;
}
#  check for ssneb
$ssneb_flag = `grep 'LNEBCELL' 01/OUTCAR|tail -1`;
@ssneb_flag = split(/\s+/,$ssneb_flag);
$ssneb_flag = $ssneb_flag[@ssneb_flag-1];
$nions = `grep 'NIONS' 01/OUTCAR|tail -1`;
@nions = split(/\s+/,$nions);
$nions = $nions[@nions-1];

if ($ssneb_flag =~ /T/){
    open NEBSS , ">nebss.dat" ;
    #print "$ssneb_flag \n";
}
  
#  print "#Directories found: ".join(" ",@directories)."\n";

$dist_cum = 0;
for ($i=0; $i<@directories; $i++) {
    (-e "$directories[$i]/OUTCAR") || die "No OUTCAR in $directories[$i]!\n";

    $energy = `grep 'energy  w' $directories[$i]/OUTCAR|tail -1`;
#    $dist = `grep 'NEB: distance' $directories[$i]/OUTCAR|tail -1`;
    $force = `grep 'NEB: projections' $directories[$i]/OUTCAR|tail -1`;
    if ($ssneb_flag =~ /T/){
        $force = `grep 'NEBCELL: projections' $directories[$i]/OUTCAR|tail -1`;
    };

    $energy =~ s/\s+$//g;
    @energy = split(/\s+/,$energy);
    $energy = $energy[@energy-1];

    if ($i==0) { $energy0 = $energy; }
    $energy -= $energy0;

    if ($i>0) {
        if (-e "$directories[$i]/CONTCAR") {
            $file1 = "$directories[$i]/CONTCAR";
        } else {
            $file1 = "$directories[$i]/POSCAR";
        }
        if (-e "$directories[$i-1]/CONTCAR") {
            $file2 = "$directories[$i-1]/CONTCAR";
        } else {
            $file2 = "$directories[$i-1]/POSCAR";
        }
        $dist = `$Bin/dist.pl $file1 $file2`;
        if ($ssneb_flag =~ /T/){
            if($i == @directories-1){ 
            $dist = $dist1[@dist1-2];
            } else{
            $dist1 = `grep 'NEBCELL: distance' $directories[$i]/OUTCAR|tail -1`;
            @dist1 = split(/\s+/,$dist1);
            $dist = $dist1[@dist1-3];}
        }
    } else {
       $dist = 0;
    }

    @force = split(/\s+/,$force);
    $force = $force[@force-1];

    $dist_cum += $dist;

    if ($ssneb_flag !~ /T/){
    # Get the coordinates to find the local tangent for the end images
    if($i == 0) {
        if (-e "$directories[$i]/CONTCAR") {
            $file1 = "$directories[$i]/CONTCAR";
        } else {
            $file1 = "$directories[$i]/POSCAR";
        }
        if (-e "$directories[$i+1]/CONTCAR") {
            $file2 = "$directories[$i+1]/CONTCAR";
        } else {
            $file2 = "$directories[$i+1]/POSCAR";
        }
        $ocar = "$directories[$i]/OUTCAR";
        $force = `$Bin/nebforces.pl $file1 $file2 $ocar`;
    } elsif($i == @directories-1) {
        if (-e "$directories[$i]/CONTCAR") {
            $file1 = "$directories[$i]/CONTCAR";
        } else {
            $file1 = "$directories[$i]/POSCAR";
        }
        if (-e "$directories[$i-1]/CONTCAR") {
            $file2 = "$directories[$i-1]/CONTCAR";
        } else {
            $file2 = "$directories[$i-1]/POSCAR";
        }
        $ocar = "$directories[$i]/OUTCAR";
        $force = `$Bin/nebforces.pl $file1 $file2 $ocar`;
    }
    }
    printf NEB "%3i %12.6f %12.6f %12.6f %3i\n",$i,$dist_cum,$energy,$force,$directories[$i];
    if ($ssneb_flag =~ /T/){
        printf NEBSS "%3i %12.6f %12.6f %12.6f %3i\n",$i,$dist_cum/sqrt($nions),$energy/$nions,$force/sqrt($nions),$directories[$i];
        }
    }
#print "nebbarrier.pl done \n";
close NEB;
if ($ssneb_flag !~ /T/){close NEBSS;}


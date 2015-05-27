#!/usr/bin/env perl
#;-*- Perl -*-

# 29-05-2003

# After vto has been run, go into the dir from vto <dir>.
# All the OUTCARs should now be zipped.

# nebmovie.pl should use CONTCARs not POSCARs.

use Cwd;
$dir = cwd;
use FindBin qw($Bin);

# Unzip the OUTCARs
print "\n" ;
print 'Unziping the OUTCARs ... ' ;
$i=0;
$string = "00" ;
while(chdir $string) {
    if(-e "OUTCAR") { ; }
    elsif(-e "OUTCAR.gz") { system "gunzip OUTCAR.gz"; }
    elsif(-e "OUTCAR.bz2") { system "bunzip2 OUTCAR.bz2"; }
    else {die "No OUTCAR in $string\n"; }
    $i++;
    if($i < 10) { $string = "0$i"; }
    elsif($i < 100) { $string = "$i"; }
    else { die "Too many images"; }
    chdir $dir;
}
print 'done',"\n";

# The number of images, not including endpoints.
$i-=2;

# Same as the 'spline' alias
print 'Do nebbarrier.pl ; nebspline.pl',"\n";
system "$Bin/nebbarrier.pl ; $Bin/nebspline.pl";
if (-e "nebss.dat"){system "$Bin/nebspliness.pl";}

print 'Do nebef.pl',"\n";
system "$Bin/nebef.pl > nebef.dat";
if (-e "nebss.dat"){system "$Bin/nebefs.pl > nebefs.dat";}

# Generate a xyz-movie
print 'Do nebmovie.pl',"\n";
system "$Bin/nebmovie.pl CONTCAR > /dev/null";

# Generate a vasp-movie
print 'Do nebjmovie.pl',"\n";
system "$Bin/nebjmovie.pl CONTCAR > /dev/null";

# nebconverge script
print 'Do nebconverge.pl',"\n";
system "$Bin/nebconverge.pl > /dev/null";

# Zip the OUTCARs again
print 'Zipping the OUTCARs again ... ' ;
$zip = $ENV{'VTST_ZIP'};
if($zip eq ''){ $zip = 'gzip'; }

$i = 0;
$string = "00";
while(chdir $string) {
    system "$zip OUTCAR";
    $i++;
    if($i < 10) { $string = "0$i"; }
    elsif($i < 100) { $string = "$i"; }
    chdir $dir;
}
print "done\n";

print "\nForces and Energy:\n";
system "cat nebef.dat";
print "\n" ;
system "cat exts.dat";
print "\n";


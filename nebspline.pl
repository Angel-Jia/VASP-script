#!/usr/bin/env perl
#;-*- Perl -*-

@args=@ARGV;

use Cwd;
$dir = cwd;
use FindBin qw($Bin);

# default values for the aguments

if(scalar($ARGV)==0) { $args[0] = "neb.dat"; }
if(scalar($ARGV)<=1) { $args[1] = 20; }

$inputfilename = $args[0];
$NumJ = $args[1];

# read in the mep file

$inputfile = "";
open (IN,$inputfilename);
while (<IN>) {
    $_ =~ s/^\s+//g;
    $inputfile .= $_;
}
#print $inputfile;
close (IN);
@inputfile = split(/\n/,$inputfile);
$NumI = scalar @inputfile;
#print $NumI;

# load in the data: position energy force

for($i=0; $i<$NumI; $i++) {
    $line = @inputfile[$i];
    @line = split(/\s+/,$line);
    @R[$i] = @line[1];
    @E[$i] = @line[2];
    @F[$i] = @line[3];}

# calculate the cubic parameters for each interval (a,b,c,d)

for($i=0; $i<($NumI-1); $i++) {
    @dR[$i] = @R[$i+1] - @R[$i];
    $F1 = $F[$i]*@dR[$i];
    $F2 = $F[$i+1]*@dR[$i];
    $U1 = $E[$i];
    $U2 = $E[$i+1];
    $Fs = $F1 + $F2;
    $Ud = $U2 - $U1;
    @a[$i] = $U1;
    @b[$i] = -$F1;
    @c[$i] = 3*$Ud + $F1 + $Fs;
    @d[$i] = -2*$Ud - $Fs;
}

# generating the output file containing the spline

$l = 0;
for($i=0; $i<$NumI; $i++) {
    @line = ($i,@R[$i],@E[$i],@F[$i]);
    @outputfile[$l] = join "\t",@line;
    $l++;
    if($i != ($NumI-1)) {
        for($j=1; $j<$NumJ; $j++){
            $f = $j/$NumJ;
            $Ispl = $i + $f;
            $Rspl = @R[$i] + $f*@dR[$i];
            $Espl = @d[$i]*$f**3 + @c[$i]*$f**2 + @b[$i]*$f + @a[$i];
            $Fspl = -(3*@d[$i]*$f**2 + 2*@c[$i]*$f + @b[$i])/@dR[$i];
            @line = ($Ispl,$Rspl,$Espl,$Fspl);
            @outputfile[$l] = join "\t",@line;
            $l++;
        }
    }
}

# writing the spline to the output file spline.dat

$outputfile = join "\n",@outputfile;
open (OUT,">spline.dat");
print OUT $outputfile;
close (OUT);

# finding extrema along the MEP

$NumE = 0;
for($i=0; $i<($NumI-1); $i++){
    $Desc = @c[$i]**2-3*@b[$i]*@d[$i];
    if($Desc >= 0) {
        $f = -1;
        # Quadratic case  
        if (@d[$i] == 0 && @c[$i] != 0) {
            $f = -(@b[$i]/(2*@c[$i]));
        # Cubic case 1
        } elsif (@d[$i]!=0) {
            $f = -(@c[$i] + sqrt($Desc))/(3*@d[$i]);
        }
        if ($f >= 0 && $f <= 1) {
            $Pos = $i + $f;
            $Ext{$Pos} = @d[$i]*$f**3 + @c[$i]*$f**2 + @b[$i]*$f + @a[$i];
            $NumE++;
        }
        # Cubic case 2
        if (@d[$i] != 0) {
            $f = -(@c[$i] - sqrt($Desc))/(3*@d[$i]);
            if ($f >= 0 && $f <= 1) {
                $Pos = $i + $f;
                $Ext{$Pos} = @d[$i]*$f**3 + @c[$i]*$f**2 + @b[$i]*$f + @a[$i];
                $NumE++;
            }
        }
    }
}

# write out the extrema information to exts.dat

open (OUT,">exts.dat");
$NumE = 0;
foreach $Pos (sort {$a<=>$b} (keys(%Ext))){
    $NumE++;
    $outline = sprintf("Extrema %d found at image %9.6f with energy: %9.6f\n",$NumE,$Pos,$Ext{$Pos});
    print OUT $outline;
}
close (OUT);

system "gnuplot $Bin/nebplot.gnu > /dev/null";

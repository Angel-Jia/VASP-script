#!/usr/bin/env perl
#;-*- Perl -*-

@ARGV == 1 || die "usage: con2xyz.pl <file.con>\n";
$inputfilename = $ARGV[0];
$outputfilename = $inputfilename;
$outputfilename =~ s/con/xyz/;

print "writing to $outputfilename\n";

$inputfile = "";
open(IN,$inputfilename);
while(<IN>) { $inputfile .= $_; }
close(IN);
@inputfile = split(/\n/,$inputfile);
foreach(@inputfile) { $_ =~ s/^\s+//; }

$descript = $inputfile[9];
$ntypes = $inputfile[6];
$ntypes =~ s/\s+.*//g;
$natoms = $inputfile[7];
@natoms = split(/\s+/,$natoms);
$totatoms = 0;
for($i=0; $i<$ntypes; $i++) {
    $totatoms += $natoms[$i];
}
print "Total: $totatoms\n";

$outfile = $totatoms."\n";
$outfile .= "Generated with con2xyz\n";

$ln = 9;
for($type=0; $type<$ntypes; $type++) {
    @line = split(/\s+/,$inputfile[$ln]);
    if(scalar(@line)>0) {
        $atype = @line[0];
    } else {
        $atype = "Type"."$type+1";
    }
    $ln += 2;
    for($i=0; $i<$natoms[$type]; $i++) {
        @line = split(/\s+/,$inputfile[$ln]);
        $outfile .= $atype."   ".join("   ",@line[0..2])."\n";
        $ln++;
    }
}
open (OUT,">$outputfilename");
print OUT $outfile;
close (OUT);

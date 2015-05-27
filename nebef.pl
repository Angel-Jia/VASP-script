#!/usr/bin/env perl
#;-*- Perl -*-

# Script prints the force, energy etc of OUTCAR's in immediate subdir
# of present working directory.

use Cwd;

$dir = cwd;
$outlist =`ls -1 "$dir"/[0-9][0-9]/OUTCAR`;   #specifies location of OUTCARs
@outlist = split("\n",$outlist);

$i = 0;
foreach $outfile (@outlist) {
    $energy = `grep 'energy  without' "$outfile" | tail -n 1 |cut -c 67-78`;
    $force =  `grep 'max\ at' "$outfile" | tail -n 1 |cut -c 27-38`;
    if(!$i) { $e0 = $energy; }
    $rel = $energy - $e0;
    @f4 = ($i,$force,$energy,$rel);
    printf "%4i %16.6f %16.6f %16.6f \n",@f4;
    $i++;
}


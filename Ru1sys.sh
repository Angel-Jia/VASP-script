#!/bin/bash
#vas2xyz.pl ts.vasp
in=$1
out="$1.xyz"
moviecombine.pl $in $in $in 12.xyz 13.529 0 0
moviecombine.pl 12.xyz 12.xyz 12.xyz final.xyz 0 12.8448 0
rm 12.xyz
mv final.xyz $out

#!/bin/bash
#vas2xyz.pl ts.vasp
in=$1
moviecombine.pl $in $in 12.xyz 5.4116 0 0
moviecombine.pl 12.xyz $in 123.xyz 10.8232 0 0
moviecombine.pl 123.xyz 123.xyz 123123.xyz 2.7058000565 4.6865831729 0
moviecombine.pl 123123.xyz 123.xyz final.xyz 5.4116 9.37316634 0
rm 12.xyz 123.xyz 123123.xyz
mv final.xyz $in

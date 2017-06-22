#!/bin/bash
#vas2xyz.pl ts.vasp
moviecombine.pl $1 $2 12.xyz 9.9550820148943 0 0
moviecombine.pl 12.xyz $2 123.xyz -9.9550820148943 0 0
moviecombine.pl 123.xyz 123.xyz 123123.xyz -4.9775410074471500 8.6213539216560395 0
moviecombine.pl 123123.xyz 123.xyz final.xyz 4.9775410074471500 -8.6213539216560395 0
rm 12.xyz 123.xyz 123123.xyz
mv final.xyz $1

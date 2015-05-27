#!/bin/bash
out="$1.xyz"
moviecombine.pl $1 $1 12.xyz -22.57063 0 0
moviecombine.pl 12.xyz $1 123.xyz -5.64266 9.7755 0
moviecombine.pl 123.xyz $1 1234.xyz -28.2133 9.7755 0
rm 12.xyz 123.xyz
mv 1234.xyz $out

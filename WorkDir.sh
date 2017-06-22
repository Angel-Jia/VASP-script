#!/bin/bash

yhqueue
echo ""

for j in `yhqueue| sed '1d'| awk '{print $1}'`
do
  mydir=`yhcontrol show jobs $j| grep "WorkDir"`
  echo "           $j  $mydir"
done

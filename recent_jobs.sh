#!/bin/bash
for j in `yhqueue| sed '1d'| awk '{print $1}'`
do
  result=`grep $j ~/recent_jobs.txt`
  if [ "$result" = "" ];then
    mydir=`yhcontrol show jobs $j| grep "WorkDir"`
    sub_time=`date`
    echo -e "    $j    |$sub_time|\n$mydir\n-------------------------------" >> ~/recent_jobs.txt
  fi
done

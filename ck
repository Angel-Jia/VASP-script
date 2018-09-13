#!/bin/bash
# check information before running vasp

echo ""
echo "KPOINTS:"
tail -3 KPOINTS
echo ""

echo "POTCAR:"
grep "TITEL" POTCAR
echo ""

if [ -e POSCAR ];then
    echo "POSCAR:"
    sed -n '6,8p' POSCAR
    flagck.py
elif [ -e 00/POSCAR ];then
    echo "00/POSCAR:"
    sed -n '6,8p' 00/POSCAR
    cd 00/
    flagck.py
    cd ..
else
    echo "POSCAR do not exit!"
fi

dir=`pwd`
if [[ $dir =~ dimer ]];then
  if [ ! -f MODECAR ];then
    echo ""
    echo "    !!!!!warning: MODECAR undetected!!!!!"
    echo ""
  fi
fi



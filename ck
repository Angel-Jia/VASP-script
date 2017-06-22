#!/bin/bash
echo ""
echo "KPOINTS:"
tail -3 KPOINTS
echo ""

echo "POTCAR:"
grep "TITEL" POTCAR
echo ""

if [ -e POSCAR ]
then
    echo "POSCAR:"
    sed -n '6,8p' POSCAR
elif [ -e 00/POSCAR ]
then
    echo "00/POSCAR:"
    sed -n '6,8p' 00/POSCAR
else
    echo "POSCAR do not exit!"
fi

echo ""
echo ""

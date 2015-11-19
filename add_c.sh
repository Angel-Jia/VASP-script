#!/bin/bash
#Usage: add_c.sh (gjf file) (three coordinate) (one H that you want delete)
name=${1/%gjf/bak}
cp $1 $name
sed -i '1,5d' $name
sed -n "$2p" $name >c_coor
sed -n "$3p" $name >>c_coor
sed -n "$4p" $name >>c_coor
sed -i "$5d" $name 
cat c_coor ~/bak/16C_coor_inner >c_coor_inner
sed -i '/^[[:space:]]*$/d' c_coor_inner
ic2cc.pl c_coor_inner
cat $name c_coor_inner.car >c_coor
sed -i '/^[[:space:]]*$/d' c_coor
mysort.pl c_coor
head -5 $1 >POSCAR-16C.gjf
cat c_coor >>POSCAR-16C.gjf

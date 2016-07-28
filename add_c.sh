#!/bin/bash
#Usage: add_c.sh (gjf file) (three coordinate) (one H that you want delete)
name=${1/%gjf/tmp}
cp $1 $name
if [ ! -e POSCAR.bak ];then
    cp POSCAR POSCAR.bak
fi

sed -i '1,5d' $name
sed -n "$2p" $name >c_coor
sed -n "$3p" $name >>c_coor
sed -n "$4p" $name >>c_coor
sed -i "$5d" $name

cat c_coor ~/bak/16C_coor_inner >c_coor_inner
sed -i '/^[[:space:]]*$/d' c_coor_inner
ic2cc.pl c_coor_inner
sed -i '1,3d' c_coor_inner.car
cat $name c_coor_inner.car >c_coor
sed -i '/^[[:space:]]*$/d' c_coor
mysort.pl c_coor
head -5 $1 >POSCAR-18C.gjf
cat c_coor >>POSCAR-18C.gjf
gv2vas.pl ~/bak/POSCARmod POSCAR-18C.gjf
mv POSCAR-18C.vasp POSCAR
rm c_coor* *.gjf *.vasp POSCAR.tmp
sed -i -f ~/bak/sed_addTTT POSCAR
vas2gv.pl POSCAR
mv POSCAR.gjf POSCAR-18C.gjf

for i in is fs
do
    if [ -x $i ];then
        sed -i '/IBRION/s/2/1/' $i
        sub $i
        exit
    elif [ -x relax ];then
        rm relax
        cp ../is/is ts
        sed -i '/IBRION/s/2/1/' ts
        sed -i '/NSW/s/500/80/' ts
        sub ts
        exit
    fi
done

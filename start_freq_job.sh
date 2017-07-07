#!/bin/bash

if [ ! -d $1 ];then
  mkdir $1
fi

vas2gv.pl CONTCAR
mv CONTCAR.gjf $1/temp.gjf

if [ -n "$2" ];then
  cp $2/POSCAR $1
  cp KPOINTS $1
  cp POTCAR $1
  if [ -f vdw_kernel.bindat ];then
      cp vdw_kernel.bindat $1
  fi
  for i in `ls $2`
  do
    if [ -x $2/$i ];then
      cp $2/$i $1
    fi
  done
fi

cd $1
if [ ! -f POSCAR ];then
  echo "POSCAR: No such file"
  echo ""
  exit
fi

gv2vas.pl POSCAR temp.gjf
mv *vasp POSCAR

#sub sub


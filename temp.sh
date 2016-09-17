#!/bin/bash
mv CONTCAR POSCAR
dir2car.pl POSCAR
mv POSCAR-C.vasp POSCAR
sed -i '28c\  EDIFFG = -0.01' sub
clc
sub sub



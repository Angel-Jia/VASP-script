#!/bin/env python3

import sys
from VASP import readVasp
from VASP import writeXYZ

if len(sys.argv) == 1:
    print('')
    print('Usage: %s vasp_file1 vasp_file2 ...' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)

print('')
print("############### This script converts vasp file into .xyz file ###############")
print("             ############ CONTCAR or POSCAR -> .xyz ############")
print('')

for vasp_file in sys.argv[1:]:
    print('                            Processing %s' % vasp_file)
    lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective = readVasp(vasp_file)
    if vasp_file.endswith('.vasp'):
        vasp_file = '%s.xyz' % vasp_file[:-5]
    else:
        vasp_file = '%s.xyz' % vasp_file
    writeXYZ(vasp_file, 1, elements, num_atoms, coordinates)

print('')
print("              --------------------- DONE ---------------------\n")
print('')

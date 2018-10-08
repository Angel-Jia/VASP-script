#!/bin/env python3

import sys
from VASP import readVasp
from VASP import writeGjf

if len(sys.argv) == 1:
    print('')
    print('Usage: %s vasp_file1 vasp_file2 ...' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)

print('')
print('############### This script converts vasp file into gview file ###############')
print('             ############ CONTCAR or POSCAR -> .gjf ############')
print('')
for vasp_file in sys.argv[1:]:
    print('                             Processing %s' % vasp_file)
    lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective = readVasp(vasp_file)
    if vasp_file.endswith('.vasp'):
        vasp_file = '%s.gjf' % vasp_file[:-5]
    else:
        vasp_file = '%s.gjf' % vasp_file
    writeGjf(vasp_file, elements, num_atoms, coordinates)

print('')
print('                     --------------- Done ---------------\n')

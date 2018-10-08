#!/bin/env python3

import sys
from VASP import readGjf, readVasp, writeVasp

if len(sys.argv) == 1:
    print('')
    print('Usage: %s POSCAR gjf_file1 gjf_file2 ...' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)

print('')
print('############### This script converts gjf file into vasp file ###############')
print('             ################# .gjf → .vasp #################')

print('')
lattice, basis, _, _, selectiveflag, coordinate_type, _, selective = readVasp(sys.argv[1])
for gjf_file in sys.argv[2:]:
    print('                           Processing %s' % gjf_file)
    elements, num_atoms, coordinates = readGjf(gjf_file)
    if gjf_file.endswith('.gjf'):
        gjf_file = '%s.vasp' % gjf_file[:-4]
    else:
        gjf_file = '%s.vasp' % gjf_file
    writeVasp(gjf_file, lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective)

print('')
print('             --------------------  DONE  --------------------')
print('')

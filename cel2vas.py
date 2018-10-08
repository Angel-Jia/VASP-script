#!/bin/env python3

from VASP import readCell, writeVasp
import sys

if len(sys.argv) < 2:
    print('')
    print('Usage: %s cell_file1 cell_file2 ...' % sys.argv[0].split('/')[-1])
    print('Please try again')
    exit(1)

print('')
print('################## This script converts .cell into POSCAR ##################')
print('              ############### .cell -> POSCAR ###############')
for file_name in sys.argv[1:]:
    print('                           processing %s' % file_name)
    basis, elements, num_atoms, coordinate_type, coordinates = readCell(file_name)
    writeVasp(file_name.replace('.cell', '.vasp'), 1.0, basis, elements,
              num_atoms, '', coordinate_type, coordinates, [])

print('                  ----------------- Done -----------------\n')

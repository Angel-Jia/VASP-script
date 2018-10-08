#!/bin/env python3

import sys
import numpy as np
from VASP import readXYZ


def writeCoordinates(base, file_handle):
    for pos in ret_coordinates:
        index = base
        for i, atoms in enumerate(num_atoms):
            for j in range(atoms):
                file_handle.write("%2s    %16.10f    %16.10f    %16.10f\n" % (elements[i],
                                  pos[index][0], pos[index][1], pos[index][2]))
                index += 1


if len(sys.argv) < 6:
    print('')
    print('Usage: %s xyz_file1 xyz_file2 ... X Y Z' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)

print('')
print("############### Merging xyz files into one single file ###############")
print('')

offset = np.array(list(map(float, sys.argv[-3:])))
xyz_files = [readXYZ(file_name) for file_name in sys.argv[1:-3]]

elements = xyz_files[0][1]
num_atoms = xyz_files[0][2]
for i, xyz_file in enumerate(xyz_files):
    if xyz_file[0] != xyz_files[0][0]:
        print('')
        print('ERROR: number of structures not equal, %s' % sys.argv[i + 1])
        print('')
        exit(1)

num_structures = xyz_files[0][0]
read_coordinates = np.array([pos[3] for pos in xyz_files])
ret_coordinates = []
for i, pos in enumerate(read_coordinates):
    ret_coordinates.append(pos + offset * i)

atoms_in_single_file = sum(xyz_files[0][2])
total_atoms = atoms_in_single_file * len(xyz_files)
base = 0
with open('merge.xyz', 'w') as merge_file:
    for frame in range(num_structures):
        merge_file.write('%d\n' % total_atoms)
        merge_file.write('create from python\n')
        writeCoordinates(base, merge_file)
        base += atoms_in_single_file

print('')
print("           --------------------- DONE ---------------------\n")

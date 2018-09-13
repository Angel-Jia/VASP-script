#!/bin/env python3

import sys
from VASP import readVasp

threshold = 0.001
if len(sys.argv) == 4:
    threshold = float(sys.argv[3])
elif len(sys.argv) != 3:
    print('')
    print("usage: poscar.py POSCAR1 POSCAR2 threshold")
    print("try again!")
    print('')
    exit(1)

lattice1, basis1, elements1, num_atoms1, selectiveflag1, coordinate_type1, coordinates1, selective1 = readVasp(sys.argv[1])
lattice2, basis2, elements2, num_atoms2, selectiveflag2, coordinate_type2, coordinates2, selective2 = readVasp(sys.argv[2])


if abs(lattice1 - lattice2) > threshold:
    print('')
    print("Lattices are different:")
    print("%s: %10.5f" % (sys.argv[1], lattice1))
    print("%s: %10.5f" % (sys.argv[2], lattice2))
    print('')

basis_diff = []
for i in range(0, 3):
    for j in range(0, 3):
        if abs(basis1[i][j] - basis2[i][j]) > threshold:
            basis_diff.append([i, j, basis1[i][j] - basis2[i][j]])

if basis_diff:
    print('')
    print("Basis are differernt:")
    print("    basis_id(within 3*3 array)            difference")
    for i in basis_diff:
        print("        (%4d,%4d)                  %14.10f" % (i[0] + 1, i[1] + 1, i[2]))
    print('')

if elements1 != elements2:
    print('')
    print("Elements are differernt:")
    print("%s: " % sys.argv[1], elements1)
    print("%s: " % sys.argv[2], elements2)
    print("")
    exit(0)

if num_atoms1 != num_atoms2:
    print('')
    print("Number of atoms are different:")
    print("%s: " % sys.argv[1], num_atoms1)
    print("%s: " % sys.argv[2], num_atoms2)
    print("")
    exit(0)

coordinate_diff = []
for i in range(0, len(coordinates1)):
    for j in range(0, 3):
        if abs(coordinates1[i][j] - coordinates2[i][j]) > threshold:
            coordinate_diff.append([i, j, coordinates1[i][j] - coordinates2[i][j]])

if coordinate_diff:
    print("")
    print("coordinates are different: ")
    print("      atoms_id              difference")
    for i in coordinate_diff:
        print("    (%4d,%4d)          %14.10f" % (i[0] + 1, i[1] + 1, i[2]))
    print("")

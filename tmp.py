#!/bin/env python3

from VASP import readVasp
import sys
import math


def dist(atom1, atom2):
    return math.sqrt(abs(atom1[0] - atom2[0]) ** 2 + abs(atom1[1] - atom2[1]) ** 2 + abs(atom1[2] - atom2[2]) ** 2)

lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective = readVasp(sys.argv[1])


distance = []
for i in range(len(coordinates) - 1):
    for j in range(i + 1, len(coordinates)):
        distance.append([i, j, dist(coordinates[i], coordinates[j])])

distance.sort(key=lambda x: x[2])

for i in range(10):
    print(distance[i])

#!/bin/env python
# -*- coding=utf-8 -*-

import re
import VASP
import sys

elements = []
coordinates = []
space = re.compile(r'\s+')

with open(sys.argv[1]) as gjf_file:
    content = gjf_file.readlines()
    index = 1
    while 1:
        if content[index].strip() == '':
            index += 4
            break
        index += 1

    while 1:
        if content[index].strip() == '':
            break
        lines = space.split(content[index].strip())
        elements.append(lines[0])
        coordinates.append([float(lines[2]), float(lines[3]), float(lines[4])])
        index += 1

total_atoms = len(elements)
content = VASP.grep_outcar("grep 'Standard orientation:' -A %d %s" % (total_atoms + 5, sys.argv[1][:-4] + '.log'))

with open(sys.argv[1][:-4] + '.xyz', 'w') as xyz_file:
    # xyz_file.write(str(total_atoms) + '\n')
    # xyz_file.write('Create from *.log file\n')
    # for element, coor in zip(elements, coordinates):
    #     xyz_file.write("%2s    %16.10f    %16.10f    %16.10f\n" % (element, coor[0], coor[1], coor[2]))

    pattern = re.compile(r'Standard orientation:')
    index = 0
    while index < len(content):
        while index < len(content):
            if pattern.search(content[index]) is not None:
                index += 5
                break
            index += 1

        if index >= len(content):
            break

        xyz_file.write(str(total_atoms) + '\n')
        xyz_file.write('Create from *.log file\n')

        for element in elements:
            lines = space.split(content[index].strip())
            xyz_file.write("%2s    %16.10f    %16.10f    %16.10f\n" %
                           (element, float(lines[3]), float(lines[4]), float(lines[5])))
            index += 1

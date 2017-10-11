#!/bin/env python

import sys
import re
from VASP import read_poscar
from VASP import write_poscar


if len(sys.argv) != 3 and len(sys.argv) != 4:
    print "\n"
    print "usage: chgflag.py line1,line2,.... T/F vaspfile"
    print "the format of line1,line2,... can be either x or x-x"
    print "try again"
    print "\n"
    exit(0)


flag = sys.argv[-2]
if flag != 'T' and flag != 'F':
    print "error: unidentified flag %s" % flag
    exit(1)

lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective = read_poscar(sys.argv[-1])

edit_line_number = []
pattern = re.compile(r'-')
if len(sys.argv) == 4:
    line_number = re.split(',', sys.argv[1])
    for num in line_number:
        if pattern.search(num):
            num_list = pattern.split(num)
            num_list[0] = int(num_list[0]) - 1
            num_list[1] = int(num_list[1])
            for i in xrange(num_list[0], num_list[1]):
                edit_line_number.append(i)
        else:
            edit_line_number.append(int(num) - 1)

if selectiveflag == '':
    selectiveflag = 'Selective dynamics'
    total_atoms = sum(num_atoms)
    if sys.argv[-2] == 'T':
        for i in range(0, total_atoms):
            selective.append(['F', 'F', 'F'])
    else:
        for i in range(0, total_atoms):
            selective.append(['T', 'T', 'T'])

if edit_line_number:
    for i in edit_line_number:
        selective[i] = [sys.argv[-2], sys.argv[-2], sys.argv[-2]]
else:
    for i in xrange(0, len(coordinates)):
        selective[i] = [sys.argv[-2], sys.argv[-2], sys.argv[-2]]

write_poscar(sys.argv[-1], lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective)


print "\n"
print "---------------Done---------------"
print "\n"




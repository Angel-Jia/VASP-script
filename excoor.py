#!/bin/env python

import re
import math
from VASP import read_total_atoms
from VASP import grep_OUTCAR

print ""
number_of_atoms = read_total_atoms()

string = "grep \"POSITION\" -A %d OUTCAR" % (int(number_of_atoms) + 15)
content = grep_OUTCAR(string)

space = re.compile(r'\s+')
position = re.compile(r'POSITION')

with open('OUTCAR.pos', 'w') as output_file:
    length = len(content)
    index = 0
    step = 0
    i = 0
    while i < length:
        if re.search(position, content[i]) is None:
            i += 1
            continue
        step += 1
        output_file.write("Step: %d\n" % step)
        output_file.write(content[i + 1])
        i += 2
        base = i
        while i - base < number_of_atoms:
            line = space.split(content[i].strip())
            output_file.write("%10s  %10s  %10s  %10.5f\n" % (line[0], line[1], line[2],
                                                              math.sqrt(float(line[3]) ** 2 + float(line[4]) ** 2 +
                                                                        float(line[5]) ** 2)))
            i += 1
        output_file.write(content[i])
        output_file.write(content[i + 10])
        output_file.write(content[i + 12] + "\n")
        i += 14

print "    --------------------Done--------------------"
print ""

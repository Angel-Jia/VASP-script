#!/bin/env python

import re
import math
import sys
import os
from VASP import read_total_atoms
from VASP import grep_outcar


print ""
number_of_atoms = read_total_atoms()

string = "grep \"POSITION\" -A %d OUTCAR" % (int(number_of_atoms) + 15)
content = grep_outcar(string)

space = re.compile(r'\s+')
position = re.compile(r'POSITION')

with open('OUTCAR.pos', 'w') as output_file:
    step = 0
    i = 0
    length = len(content)
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

if len(sys.argv) != 1:
    length = len(sys.argv)
    pattern = re.compile(r'[^0-9]')
    step_list = []
    for i in xrange(1, length):
        step_list.append(int(sys.argv[i]))
    step_list.sort()

    with open('OUTCAR.pos') as input_file:
        content = input_file.readlines()
        length = len(content)
        index = 0
        steps_search = re.compile(r'^Step: ([0-9]+)')
        step_id = 0
        for i in step_list:
            while index < length:
                step_id = steps_search.search(content[index]).group(1)
                if int(step_id) != i:
                    index += number_of_atoms + 6
                    continue
                else:
                    file_name = "POSCAR%d" % i
                    os.system("head -8 POSCAR >POSCAR%d" % i)
                    with open("POSCAR%d" % i, 'a') as output_file:
                        output_file.write("Cartesian\n")
                        index += 2
                        base = index
                        while index - base < number_of_atoms:
                            line = space.split(content[index].strip())
                            output_file.write("  %10.5f    %10.5f    %10.5f F F F\n" % (float(line[0]), float(line[1]),
                                                                                        float(line[2])))
                            index += 1
                    break
            index += 4

print "    --------------------Done--------------------"
print ""

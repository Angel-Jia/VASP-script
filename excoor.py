#!/bin/env python

import re
import math
from VASP import read_total_atoms
from VASP import grep_OUTCAR


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
            list = [float(line[0]), float(line[1]), float(line[2])]
            list.append(math.sqrt(list[0] ** 2 + list[1] ** 2 + list[2] ** 2))
            output_file.write("%15.5f    %15.5f    %15.5f    %15.5f\n" % (list[0], list[1], list[2], list[3]))
            i += 1
        output_file.write(content[i])
        output_file.write(content[i + 10])
        output_file.write(content[i + 12] + "\n")
        i += 14


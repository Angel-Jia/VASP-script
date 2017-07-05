#!/bin/env python

import os
import re
from VASP import read_total_atoms
from VASP import grep_OUTCAR


number_of_atoms = read_total_atoms()

string = "grep \"POSITION\" -A %d OUTCAR" % (number_of_atoms + 15)
content = grep_OUTCAR(string, 'OUTCAR.tmp')

energy =


space = re.compile(r'\s+')

with open('OUTCAR.pos', 'w') as output_file:
    cnt = 0
    step = 0
    for line in content:
        if re.search(r'-', line) is not None:
            cnt = 0
            step += 1
            output_file.write("step: %d\n" % step)
            continue
        if cnt < number_of_atoms:
            line = space.split(line.strip())
            output_file.write("%10.5f  %10.5f  %10.5f")


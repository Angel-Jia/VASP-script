#!/bin/env python3

# 提取OUTCAR中每一步的原子坐标和能量
# 用法：excoor.py
# 或：excoor.py 20 24 35 (将分别提取第20,24,35步的构型并生成相应的POSCAR文件)

import re
import math
import sys
import os
from VASP import execCmd, CmdRrror

def writePOSCAR(content, base, number_of_atoms, step):
    os.system("head -7 POSCAR > POSCAR%d" % step)
    with open("POSCAR%d" % step, 'a') as output_file:
        output_file.write("Selective dynamics\n")
        output_file.write("Cartesian\n")
        for i in range(base, base + number_of_atoms):
            line = list(map(float, space.split(content[i].strip())))
            output_file.write("  %10.5f    %10.5f    %10.5f F F F\n" % (line[0], line[1], line[2]))


space = re.compile(r'\s+')
position = re.compile(r'POSITION')


cmd = "sed -n '7p' POSCAR"
try:
    number_of_atoms = sum(map(int, space.split(execCmd(cmd)[0].strip())))
except CmdRrror:
    print(CmdRrror)
    exit(1)


cmd = 'grep "POSITION" -A %d OUTCAR' % (int(number_of_atoms) + 15)
try:
    content = execCmd(cmd)
except CmdRrror:
    print(CmdRrror)
    exit(1)

print('')
if len(sys.argv) > 1:
    step_set = set(map(int, sys.argv[1:]))
else:
    step_set = set()

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

        if step in step_set:
            writePOSCAR(content, base, number_of_atoms, step)

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

print("    --------------------Done--------------------")
print('')

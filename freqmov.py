#!/bin/env python3

import sys
from VASP import execCmd, CmdRrror
from VASP import writeXYZ
import numpy as np
import re

if len(sys.argv) < 3:
    print('')
    print('Usage: %s freq1 freq2 ... frames scale' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)

space = re.compile(r'\s+')

def readFreq(file_name):
    """
    :param file_name: str
    :return: [coordinates, dcoordinates]
    coordinates: 原子坐标(x,y,z)
    dcoordinates: 震动坐标(dx,dy,dz)
    """
    coordinates = []
    dcoordinates = []
    with open(file_name, 'r') as freq_file:
        content = freq_file.readlines()
    index = 2
    while index < len(content):
        line = content[index].strip()
        if line == '':
            break

        line = list(map(float, space.split(line)))
        coordinates.append(np.array([line[0], line[1], line[2]]))
        dcoordinates.append(np.array([line[3], line[4], line[5]]))
        index += 1

    return np.stack(coordinates), np.stack(dcoordinates)


def get_elements_info():
    # 元素符号
    cmd = "grep 'VRHFIN' OUTCAR"
    try:
        content = execCmd(cmd)
    except CmdRrror:
        print(CmdRrror)
        print("")
        exit(1)
    pattern = re.compile(r'=(.*?):')
    elements = []
    for line in content:
        line = line.strip()
        elements.append(pattern.search(line).group(1))

    # 各元素原子数量
    cmd = "grep 'ions per type' OUTCAR"
    try:
        atom_num = execCmd(cmd)
    except CmdRrror:
        print(CmdRrror)
        print("")
        exit(1)

    num_atoms = list(map(int, space.split(atom_num[0].strip().split('=')[-1].strip())))
    return elements, num_atoms


print('')
print('################ This script makes animation of vibration ################')
print('')
elements, num_atoms = get_elements_info()
frames = int(sys.argv[-2])
dframe = 1 / float(frames)
scale = float(sys.argv[-1])
for freq_file in sys.argv[1:-2]:
    print('                            Processing %s' % freq_file)
    freq_pos, vibration = readFreq(freq_file)

    num_structures = 0
    coordinates = []

    # 0→1
    for i in range(0, frames + 1):
        num_structures += 1
        coordinates.append(freq_pos + vibration * dframe * i * scale)

    # 1→0
    for i in range(frames, -1, -1):
        num_structures += 1
        coordinates.append(freq_pos + vibration * dframe * i * scale)

    # 0→-1
    for i in range(-1, -frames - 1, -1):
        num_structures += 1
        coordinates.append(freq_pos + vibration * dframe * i * scale)

    # -1→0
    for i in range(-frames, 0):
        num_structures += 1
        coordinates.append(freq_pos + vibration * dframe * i * scale)

    coordinates = np.concatenate(coordinates)

    writeXYZ('%s.xyz' % freq_file, num_structures, elements, num_atoms, coordinates)

print('')
print('                ------------------ Done ------------------\n')

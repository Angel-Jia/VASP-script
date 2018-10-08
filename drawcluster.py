#!/bin/env python3

import sys
import os
from VASP import readCell
import re
import numpy as np

"""
crystal_conf.txt 格式:
x, y, z             //在x,y,z三个方向上晶胞的数量
h, k, l, distance   //晶面指标,距离原点的距离
...
h, k, l, distance   //晶面指标,距离原点的距离
"""

if len(sys.argv) == 1:
    print('')
    print('Usage: %s cell_file' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)

if not os.path.isfile('crystal_conf.txt'):
    print('')
    print('Error: crystal_conf.txt missing!')
    print('')
    exit(1)


def product(coord, hkl):
    # 截距为0时该项置0
    if hkl == 0:
        return np.zeros(coord.shape[0])
    else:
        return coord / hkl

epsilion = 0.000001
space = re.compile(r'\s+')
with open('crystal_conf.txt', 'r') as conf_file:
    content = conf_file.readlines()
x, y, z = map(int, content[0].strip().split(','))

planes = []
for i in range(1, len(content)):
    line = content[i].strip()
    if line == '':
        break

    if line.startswith('#'):
        continue
    line = line.split(',')
    planes.append([int(line[0]), int(line[1]), int(line[2]), float(line[3])])

basis, elements, num_atoms, coordinate_type, coordinates = readCell(sys.argv[1])
basis = np.array(basis)
coordinates = np.array(coordinates)

# 构建超胞
coordinates_ret = []
for ix in range(-x, x + 1):
    coordinates_ret.append(coordinates + basis[0] * ix)
coordinates = np.concatenate(coordinates_ret)

coordinates_ret = []
for iy in range(-y, y + 1):
    coordinates_ret.append(coordinates + basis[1] * iy)
coordinates = np.concatenate(coordinates_ret)

coordinates_ret = []
for iz in range(-z, z + 1):
    coordinates_ret.append(coordinates + basis[2] * iz)
coordinates = np.concatenate(coordinates_ret)

print('')
for i, plane in enumerate(planes):
    # 知道截距时候的平面公式: x/h + y/k + z/l = 1
    print('processing plane: (%2d, %2d, %2d);  distance = %5.4f' % (plane[0], plane[1], plane[2], plane[3]))
    ret = np.zeros(coordinates.shape[0])
    ret += product(coordinates[:, 0], plane[0] * plane[3])
    ret += product(coordinates[:, 1], plane[1] * plane[3])
    ret += product(coordinates[:, 2], plane[2] * plane[3])

    coordinates = coordinates[ret < 1.0]
print('')

with open('ret.xyz', 'w') as output_file:
    output_file.write("%d\n" % coordinates.shape[0])
    output_file.write('create from python\n')
    for coord in coordinates:
        output_file.write("%2s    %16.10f    %16.10f    %16.10f\n" % (elements[0], coord[0], coord[1], coord[2]))
    output_file.write('\n')


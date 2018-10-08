#!/bin/env python3

import sys
import re
from VASP import execCmd, CmdRrror
from multiprocessing import Pool

energyPattern = re.compile(r'=.*?([-.0-9]+)')
tangentPattern = re.compile(r'([-.0-9]+).*?([-.0-9]+)')


def getInfo(image_folder):
    """
    :param image_folder: 00, 01, 02, ...
    :return:
    """
    cmd = 'grep "free  energy " ./%02d/OUTCAR' % image_folder
    try:
        energy = execCmd(cmd)
    except CmdRrror:
        print(CmdRrror)
        exit(1)

    for i in range(len(energy)):
        energy[i] = float(energyPattern.search(energy[i]).group(1))

    # try:
    #     cmd = 'grep "distance to prev" ./%02d/OUTCAR' % image_folder
    # except CmdRrror:
    #     print(CmdRrror)
    #     exit(1)
    # dist = execCmd(cmd)

    cmd = 'grep "projections on to tangent" ./%02d/OUTCAR' % image_folder
    try:
        tangent = execCmd(cmd)
    except CmdRrror:
        print(CmdRrror)
        exit(1)
    for i in range(len(tangent)):
        tangent[i] = float(tangentPattern.search(tangent[i]).group(2))

    cmd = 'grep "FORCES: max atom" ./%02d/OUTCAR' % image_folder
    try:
        force = execCmd(cmd)
    except CmdRrror:
        print(CmdRrror)
        exit(1)
    for i in range(len(force)):
        force[i] = float(tangentPattern.search(force[i]).group(1))

    return [energy, tangent, force]


if len(sys.argv) == 1:
    print('')
    print('Usage: %s number_of_images' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)


print('##########This script is used to get information about energy, distance, force##########')
print('')

pool = Pool(4)
folder_ids = [folder_id for folder_id in range(1, int(sys.argv[1]) + 1)]
info = pool.map(getInfo, folder_ids)

best_ret = []
for step in range(len(info[0][0])):
    print('step: %d' % (step + 1))
    print('              Energy      Tangent    Max force')
    for i, each_info in enumerate(info):
        # energy, tangent, force
        print('images: %d  %10.5f  %10.5f  %10.5f' % (i + 1, each_info[0][step], each_info[1][step],
                                                        each_info[2][step]))
        # step, tangent, force
        best_ret.append([step + 1, i + 1, abs(each_info[1][step]), each_info[2][step]])
    print('')

# sorted by tangent
best_ret.sort(key=lambda x: x[2])
print('')
print('-------------- Best Result --------------')
print('  Step    Image_id     Tangent    Max force')
for i in range(min(10, len(best_ret))):
    print('%5d      %4d     %10.5f  %10.5f' % (best_ret[i][0], best_ret[i][1], best_ret[i][2], best_ret[i][3]))
print('')


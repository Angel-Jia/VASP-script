#!/bin/env python3

import sys
import os

if len(sys.argv) < 2:
    print('')
    print('Usage: %s POSCAR gjf_file1 gjf_file2 ...' % sys.argv[0].split('/')[-1])
    print('')
    exit(1)


print('############### Replacing images with gvfile ###############')
print('')
os.system('gjf2vas.py %s > /dev/null' % (' '.join(sys.argv[1:])))
folder_id = 1
for gjf_file in sys.argv[2:]:
    print('%28s → %02d' % (gjf_file, folder_id))
    vasp_file = '%s.vasp' % gjf_file[:-4]
    os.system('mv %s %02d/POSCAR' % (vasp_file, folder_id))
    folder_id += 1

print('')
print('          ###############  DONE  ###############\n')

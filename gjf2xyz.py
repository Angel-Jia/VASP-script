#!/bin/env python3

import re
from VASP import readGjf, writeXYZ
import sys

space = re.compile(r'\s+')

if len(sys.argv) == 1:
    print("")
    print("Usage: %s line1,line2,.... T/F vaspfile" % sys.argv[0].split('/')[-1])
    print("the format of line1,line2,... can be either x or x-x")
    print("try again")
    print("")
    exit(1)


print('')
print('############ This script converts gjf to xyz ############')
print('          ############ gjf -> xyz ############')
print('')
for gjf_file in sys.argv[1:]:
    print('                  processing %s' % gjf_file)
    elements, num_atoms, coordinates = readGjf(gjf_file)
    if gjf_file.endswith('.gjf'):
        gjf_file = '%s.xyz' % gjf_file[:-4]
    else:
        gjf_file = '%s.xyz' % gjf_file
    writeXYZ(gjf_file, 1, elements, num_atoms, coordinates)

print('')
print('               ---------- Done ----------')

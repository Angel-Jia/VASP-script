# -*- coding=utf-8 -*-

import VASP
import sys

# if len(sys.argv) < 4:
#     print "Usage: gvextend.py file1 file2 ... X Y Z"
#     print "Try again!"
#     exit(0)

elements, num_atoms, coordinates = VASP.read_gjf('temp.gjf')
print elements
print num_atoms


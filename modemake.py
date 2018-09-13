#!/bin/env python3

import sys
import re

if len(sys.argv) != 3:
    print('')
    print("Usage: %s freqfile scale" % sys.argv[0])
    print("Please try again!")
    print('')
    exit(0)

print('')
with open(sys.argv[1]) as input_file:
    content = input_file.readlines()
scale = float(sys.argv[2])

with open('MODECAR', 'w') as output_file:
    length = len(content)
    space = re.compile(r'\s+')
    for i in range(2, length):
        line = content[i].strip()
        if line == "":
            break
        line = list(map(float, space.split(line)))
        output_file.write("%10.5f  %10.5f  %10.5f\n" % (line[3] * scale, line[4] * scale, line[5] * scale))

print("    --------------------Done--------------------")
print('')

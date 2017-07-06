#!/bin/env python

import sys
import re

if len(sys.argv) != 2:
    print ""
    print "Usage: freq.pl freqfile"
    print "Please try again!"
    print ""
    exit(0)

print ""
content = []
with open(sys.argv[1]) as input_file:
    content = input_file.readlines()

with open('MODECAR', 'w') as output_file:
    length = len(content)
    space = re.compile(r'\s+')
    for i in xrange(2, length):
        line = content[i].strip()
        if line == "":
            break
        line = space.split(line)
        output_file.write("%10.5f  %10.5f  %10.5f\n" % (float(line[3]), float(line[4]), float(line[5])))

print "    --------------------Done--------------------"
print ""
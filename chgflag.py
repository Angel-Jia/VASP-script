#!/bin/env python

import sys
import re


def process(lines):
    space = re.compile(r'\s+')
    base = 8
    length = len(lines)
    if line_edit == '':
        i = 1
        while i + base < length:
            line = space.split(str.strip(lines[i + base]))
            lines[i + base] = " %20.16f  %20.16f  %20.16f %s %s %s\n" %\
                              (float(line[0]), float(line[1]), float(line[2]), flag, flag, flag)
            i += 1
        return lines
    else:
        lines_edit = line_edit.replace(' ', '').split(',')
        for line_number in lines_edit:
            line_numbers = line_number.split('-')
            if len(line_numbers) == 1:
                i = int(line_numbers[0])
                line = space.split(str.strip(lines[i + base]))
                lines[i + base] = " %20.16f  %20.16f  %20.16f %s %s %s\n" %\
                                  (float(line[0]), float(line[1]), float(line[2]), flag, flag, flag)
            else:
                if int(line_numbers[0]) > int(line_numbers[1]):
                    print "error: edit lines are wrong  %s-%s" % (line_numbers[0], line_numbers[1])
                    exit(1)

                for i in xrange(int(line_numbers[0]), int(line_numbers[1]) + 1):
                    line = space.split(str.strip(lines[i + base]))
                    lines[i + base] = " %20.16f  %20.16f  %20.16f %s %s %s\n" %\
                                      (float(line[0]), float(line[1]), float(line[2]), flag, flag, flag)
        return lines


if len(sys.argv) != 3 and len(sys.argv) != 4:
    print "usage: chgflag line_number(xx, xx-xx, split with ',') flag(T or F) file_name"
    print "Please try again"
    exit(0)


flag = sys.argv[-2]
if flag != 'T' and flag != 'F':
    print "error: unidentified flag %s" % flag
    exit(1)

i = 1
line_edit = ''
while sys.argv[i] != flag:
    line_edit = line_edit + sys.argv[i] + ' '
    i += 1

file_name = sys.argv[-1]
output_file_name = 'test1'
with open(file_name) as file_input, \
        open(output_file_name, 'w') as file_output:
    lines = file_input.readlines()
    lines = process(lines)
    file_output.writelines(lines)
    for temp in lines:
        print str.rstrip(temp)






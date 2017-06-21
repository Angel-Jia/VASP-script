# -*- coding:utf-8 -*-

import sys
import re


def process(lines):
    space = re.compile(r'\s+')
    base = 9
    length = len(lines)
    if line_edit == '':
        i = 0
        while i + base < length:
            line = space.split(lines[i + base])
            lines[i + base] = "%15.6f  %15.6f  %15.6f %s %s %s" % (line[0], line[1], line[2],
                                                                   flag, flag, flag)
            i += 1
        return lines
    else:
        lines_edit = line_edit.replace(' ', '').split(',')
        for line_number in lines_edit:
            if 


if len(sys.argv) != 3 or len(sys.argv) != 4:
    print "usage: chgflag line_number(xx, xx-xx, split with ',') flag(T or F) file_name"
    print "Please try again"
    exit(0)


flag = sys.argv[-2]
if flag != "T" or flag != "F":
    print "error: unidentified flag %s" % flag
    exit(1)

i = 1
line_edit = ''
while sys.argv[i] != flag:
    line_edit = line_edit + sys.argv[i] + ' '
    i += 1

file_name = sys.argv[-1]
with open(file_name) as file_input:
    lines = file_input.readlines()
    lines = process(lines)
    print lines






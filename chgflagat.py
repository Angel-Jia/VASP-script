#!/bin/env python
# -*- coding:utf-8 -*-
import sys
import re

num_of_argv = len(sys.argv)
if num_of_argv < 3:
    print "\n"
    print "usage: chgflagat.py vaspfile line_number1 line_number2 ...."
    print "line_number can be pure number or number in the form of number1-number2"
    print "try again"
    print "\n"
    exit(0)

file_content = []
try:
    pos_file_object = open(sys.argv[1])
    file_content = pos_file_object.readlines()
    pos_file_object.close()
except:
    print "can not open file %s" % sys.argv[1]
    pos_file_object.close()
    exit(0)
num_of_file = len(file_content)
base_line = 9
cnt = 2
pattern = re.compile(r'[TF] [TF] [TF]')
for i in xrange(base_line, num_of_file):
    file_content[i] = re.sub(pattern, 'F F F', file_content[i])

while cnt < num_of_argv:
    if re.search(r'-', sys.argv[cnt]) is not None:
        lines = sys.argv[cnt].split('-')
        lines[0] = int(lines[0])
        lines[1] = int(lines[1])
        if lines[0] > lines[1] or (lines[1] + base_line) > num_of_file:
            print "wrong parameter: %s" % sys.argv[cnt]
            print "please try again!"
            exit(0)
        for i in xrange(lines[0] - 1, lines[1]):
            file_content[i + base_line] = re.sub(pattern, r'T T T', file_content[i + base_line])
    else:
        line = int(sys.argv[cnt])
        if (line + base_line) > num_of_file:
            print "wrong parameter: line %d out of range" % line
            print "please try again!"
            exit(0)
        file_content[int(sys.argv[cnt]) - 1 + base_line] = re.sub(pattern, r'T T T', file_content[int(sys.argv[cnt]) - 1 + base_line])
    cnt += 1


pos_file_object = open(sys.argv[1].replace(r'.vasp', r'') + r'-new.vasp', 'w')
try:
    for i in xrange(0, num_of_file):
        pos_file_object.write(file_content[i])
    pos_file_object.close()
except:
    print "can not open file: %s" % (sys.argv[1] + r'-new.vasp')
    pos_file_object.close()
    exit(0)

print "\n"
print "---------------Done---------------"
print "\n"

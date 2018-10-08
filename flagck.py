#!/bin/env python3
# 检查T/F标记

import re

file_name = 'POSCAR'
with open(file_name) as input_file:
    content = input_file.readlines()

pattern = re.compile('\s+')
pre_flag = []
flag = []

if re.search(r'^[Ss]', content[7]) is None:
    print('')
    print("Selective flag not found!")
    print('')
    exit(1)

print('')
print("Atom_id                      Content")
print("------------------------------------------")
for i in range(9, len(content)):
    temp = pattern.split(content[i].strip())

    if len(temp) == 1:
        exit(1)

    if len(temp) != 6:
        print("-----------")
        print("%4d:    %s" % (i - 8, content[i].rstrip()))
        print("-----------")
        continue

    if len(pre_flag) == 0:
        pre_flag = [temp[3], temp[4], temp[5]]
        flag = [temp[3], temp[4], temp[5]]
    else:
        flag = [temp[3], temp[4], temp[5]]

    if flag == pre_flag:
        continue
    else:
        pre_flag = flag
        print("%4d:    %s" % (i - 9, content[i - 1].rstrip()))
        print("%4d:    %s" % (i - 8, content[i].rstrip()))
        print("-----------")

print('')

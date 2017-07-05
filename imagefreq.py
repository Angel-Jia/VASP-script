#!/bin/env python

import re
import os

print ""
print "    --------------------Processing--------------------"
print ""
space = re.compile(r'\s+')
atoms = space.split(os.popen("sed -n '7p' POSCAR").read().strip())

if re.search(r'[a-z]', atoms[0]) is not None:
    print "POSCAR: No such file or incorrect"
    exit(0)

atom_num = 0
for i in atoms:
    atom_num += int(i)
atom_num += 2

string = "grep \"f/i\" OUTCAR -A %d" % atom_num
content = os.popen(string).readlines()

if re.search(r'No such file or directory', content[0]) is not None:
    print "OUTCAT: No such file"
    exit(0)

pattern = re.compile("([0-9]+)\s+f/i")
content_length = len(content)
freq_start = 0
freq_end = 0
freq_id = 0
for index in xrange(0, content_length):
    if content[index].strip() == "":
        freq_end = index
        file_name = "freq" + freq_id
        with open(file_name, 'w') as output_file:
            for i in xrange(freq_start, freq_end + 1):
                output_file.write(str(content[i]))
        continue

    freq_id_search = re.search(pattern, content[index])
    if freq_id_search is None:
        continue
    else:
        freq_start = index
        freq_id = freq_id_search.group(1)
        print "                          freq%s" % freq_id

print ""
print "       --------------------Done--------------------"
print ""




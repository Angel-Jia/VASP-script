#!/bin/env python

import re
from VASP import read_total_atoms
from VASP import grep_OUTCAR

print ""
print "    --------------------Processing--------------------"
print ""

atom_num = read_total_atoms()
atom_num += 2

string = "grep \"f/i\" OUTCAR -A %d" % atom_num
content = grep_OUTCAR(string)

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




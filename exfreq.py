#!/bin/env python3

import re
import sys
from VASP import execCmd, CmdRrror


if len(sys.argv) == 1:
    print("")
    print("Usage: %s -a (for all frequencies)" % sys.argv[0].split('/')[-1])
    print("Usage: %s -i (for all image frequencies)" % sys.argv[0].split('/')[-1])
    print("Please try again!")
    print("")
    exit(1)


print("")
print("    --------------------Processing--------------------")
print("")

space = re.compile(r'\s+')
cmd = "grep 'ions per type' OUTCAR"
try:
    atom_num = execCmd(cmd)
except CmdRrror:
    print(CmdRrror)
    print("")
    exit(1)

# print(atom_num[0].strip().split('=')[-1])
atom_num = sum(map(int, space.split(atom_num[0].strip().split('=')[-1].strip()))) + 2

if sys.argv[1] == '-a':
    cmd = "grep \"meV\" OUTCAR -A %d" % atom_num
if sys.argv[1] == '-i':
    cmd = "grep \"f/i\" OUTCAR -A %d" % atom_num

try:
    content = execCmd(cmd)
except CmdRrror:
    print(CmdRrror)
    exit(1)

if content is None:
    print('                      No frequencies\n')
    print("       --------------------Done--------------------\n")
    exit(1)
pattern = re.compile("([0-9]+)\s+f")
content_length = len(content)
freq_start = 0
freq_end = 0
freq_id = 0
for index in range(0, content_length):
    if content[index].strip() == "":
        freq_end = index
        file_name = "freq" + freq_id
        with open(file_name, 'w') as output_file:
            for i in range(freq_start, freq_end + 1):
                output_file.write(str(content[i]))
        continue

    freq_id_search = re.search(pattern, content[index])
    if freq_id_search is None:
        continue
    else:
        freq_start = index
        freq_id = freq_id_search.group(1)
        print("                          freq%s" % freq_id)

print('')
print("       --------------------Done--------------------\n")

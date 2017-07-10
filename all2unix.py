import re
import sys

separator = re. compile(r'\r\n')

for i in xrange(1, len(sys.argv)):
    content = ''
    with open(sys.argv[i]) as IN:
        content = IN.readlines()
    for j in xrange(0, len(content)):
        content[j] = content[j].rstrip()
    with open(sys.argv[i], 'w') as OUT:
        for line in content:
            OUT.write(line + '\n')


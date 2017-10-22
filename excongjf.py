#!/bin/env python

import sys
import os
import subprocess

default_file = 'CONTCAR'

if len(sys.argv) == 1:
    print ''
    print "Usage: excongif.py directory1 directory2 ... (file)"
    print "Please try again!\n"
    exit(0)

if not os.path.isdir(sys.argv[-1]):
    default_file = sys.argv[-1]

print ''
print '--------------------'
print "Default file: %s" % default_file
dir_list = []
for directory in sys.argv[1:]:
    if os.path.isdir(directory):
        dir_list.append(directory.rstrip('/'))
    else:
        print "%s is not a directory!" % directory

print ''
print 'Processing...'
for directory in dir_list:
        pipe = subprocess.Popen("vas2gv.pl %s" % (directory + '/' + default_file),
                                shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        error = pipe.stderr.read()
        if error != '':
            print "Error in path(%s): %s" % (directory, error)
            continue
        os.system("mv %s %s" % (directory + '/' + default_file + '.gjf', directory + '.gjf'))
print ''
print '-----Finish-----\n'

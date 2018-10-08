#!/bin/env python3

# 把指定目录中的default_file转换为gjf文件

import sys
import os
import subprocess

default_file = 'CONTCAR'

if len(sys.argv) == 1:
    print('')
    print("Usage: %s directory1 directory2 ... (default_file)" % sys.argv[0].split('/')[-1])
    print("Please try again!")
    exit(1)

if not os.path.isdir(sys.argv[-1]):
    default_file = sys.argv[-1]

print('')
print('--------------------')
print('')
print("Default file: %s" % default_file)
dir_list = []
for directory in sys.argv[1:]:
    if os.path.isdir(directory):
        dir_list.append(directory.rstrip('/'))
    else:
        print("%s is not a directory!" % directory)

print('')
print('Processing...')
for directory in dir_list:
    pipe = subprocess.Popen("vas2gjf.py %s" % (directory + '/' + default_file),
                            shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    error = pipe.stderr.read().decode()
    if error != '':
        print("Error in path(%s): %s" % (directory, error))
        continue
    os.system("mv %s/%s.gjf %s" % (directory, default_file, '%s.gjf' % directory))
print('')
print('----- Done -----')
print('')

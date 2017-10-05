#!/bin/env python
# -*- coding=utf-8 -*-

import os
import subprocess
import time
import re
import shutil

wait_directory = ''
exec_directory = ''
file_list = []
g09_file_pattern = re.compile(r'g09 (.*?gjf)')
cores_pattern = re.compile(r'^%nprocshared=([0-9]+)')


def exec_command(command):
    pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    content, _ = (pipe.stdout.read().strip(), pipe.stderr.read())
    return content


def cores_occupy():
    jobs_content = exec_command('jobs')
    cores = 0
    print jobs_content
    if jobs_content == '':
        return 0
    for line in jobs_content:
        g09_file = g09_file_pattern.search(line.strip())


os.chdir(wait_directory)
for g09_file in os.listdir(wait_directory):
    if g09_file.endswith('.gjf') and os.path.isfile(g09_file):
        file_content = exec_command('head %s' % g09_file)











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
cores_pattern = re.compile(r'%nprocshared=([0-9]+)')


def exec_command(command):
    pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return pipe.stdout.read().strip()


def cores_occupy():
    if jobs_list:
        cores_num = 0
        for job in jobs_list:
            if job[0].poll() is None:
                cores_num += job[1]
            else:
                job[2] = True

    else:
        return 0

# jobs_list存放当前运行的Gaussian程序任务列表，其中每一项任务由三个元素构成:[Popen, cores, isFinished]
# Popen是任务对象，cores是所用CPU核心数，isFinished是任务完成标记，初始为False，任务完成后变为True
jobs_list = []

os.chdir(wait_directory)
for g09_file in os.listdir(wait_directory):
    if g09_file.endswith('.gjf') and os.path.isfile(g09_file):
        # 移动文件并切换目录
        shutil.move(wait_directory + '/' + g09_file, exec_directory)
        os.chdir(exec_directory)

        # 查找需要的core数
        cores_match = cores_pattern.search(exec_command('head %s' % g09_file))
        if cores_match is None:
            print "Error: can not find key word nprocshared in file %s" % g09_file
            print "This file will be ignored!"
            continue
        cores = int(cores_match.group(1))

        #
        g09_job = subprocess.Popen('g09 %s' % g09_file, shell=True)
        jobs_list.append([g09_job, cores, False])


# 极端情况下会出错，比如正在提交gjf的时候你删除了这个文件
# 如果python出错，则所有正在运行的gjf文件都会终止

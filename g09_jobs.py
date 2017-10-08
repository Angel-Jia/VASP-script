#!/bin/env python
# -*- coding=utf-8 -*-

import os
import subprocess
import time
import re
import shutil
import signal

# 填入参数，分别是用于等待的文件夹路径，用于执行的文件夹路径和最大可以使用的CPU核心数（！是CPU核心数，不是CPU个数！）
# 需要执行的gjf文件放到'wait_directory'路径下，本脚本会自动将其移动到'exec_directory'路径中执行
# 本脚本放在哪里都可以，程序一开始会自动切换到'wait_directory'
wait_directory = '/WORK/nankai_chem_ldli_1/temp/test-1'
exec_directory = '/WORK/nankai_chem_ldli_1/temp/test-2'
max_cores = 24
interval = 10

# 注意事项
# gjf文件所用的核心数必须用关键字%nprocshared=xx来指定，否则将搜索不到

os.chdir(wait_directory)
output_file = open('output', 'w')


if not os.path.exists(wait_directory):
    output_file.write("Path '%s' is not existed\n" % wait_directory)
    output_file.write("Please check your settings!\n")
    output_file.close()
    exit(0)

if not os.path.exists(exec_directory):
    output_file.write("Path '%s' is not existed\n" % exec_directory)
    output_file.write("Please check your settings!\n")
    output_file.close()
    exit(0)

file_list = []
cores_pattern = re.compile(r'%nprocshared=([0-9]+)')


def exec_command(command):
    pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return pipe.stdout.read().strip()


def cores_occupy_query():
    global jobs_list
    if jobs_list:
        cores_num = 0
        new_jobs_list = []
        flag = False
        for job in jobs_list:
            if job[0].poll() is None:
                cores_num += job[1]
                new_jobs_list.append(job)
            else:
                output_file.write("Finished: %s\n" % job[2])
                flag = True
        if flag:
            output_file.write('\n')
            output_file.flush()
        jobs_list = new_jobs_list
        return cores_num
    else:
        return 0


def g09_file_run(g09_file_list):
    global jobs_list
    for g09_file in g09_file_list:
        if os.path.isfile(g09_file):
            # 移动文件并切换目录
            shutil.move(wait_directory + '/' + g09_file, exec_directory)
            os.chdir(exec_directory)

            # 查找需要的core数
            cores_match = cores_pattern.search(exec_command('head %s' % g09_file))
            if cores_match is None:
                output_file.write("Error: can not find key word 'nprocshared' in file: %s\n" % g09_file)
                output_file.write("This file will be ignored!\n")
                output_file.flush()
                os.chdir(wait_directory)
                continue
            cores = int(cores_match.group(1))

            # 查询已占用核心数
            cores_occupy = cores_occupy_query()
            while cores_occupy + cores > max_cores:
                time.sleep(interval)
                stop_run()
                cores_occupy = cores_occupy_query()

            if os.path.isfile(g09_file):
                output_file.write("Execute file: %s (free cores: %d)\n" % (g09_file, max_cores - cores - cores_occupy))
                output_file.flush()
                g09_job = subprocess.Popen('g09 %s' % g09_file, shell=True, preexec_fn=os.setsid)
                jobs_list.append([g09_job, cores, g09_file])
        os.chdir(wait_directory)


def kill_job_in_jobs_list(file_name):
    for job in jobs_list:
        if file_name == job[2]:
            os.killpg(os.getpgid(job[0].pid), signal.SIGTERM)
            # ---------- debug ----------
            # output_file.write("%s has been found and killed\n" % file_name)
            # output_file.flush()
            break


def stop_run():
    global jobs_list
    if os.path.isfile(wait_directory + '/STOP'):
        with open(wait_directory + '/STOP') as stop_file:
            for line in stop_file.readlines():
                line = line.strip()
                if line.endswith('.gjf'):
                    kill_job_in_jobs_list(line)
        os.remove(wait_directory + '/STOP')


# jobs_list存放当前运行的Gaussian程序任务列表，其中每一项任务由三个元素构成:[Popen, cores, file_name]
# Popen是任务对象，cores是所用CPU核心数, file_name是文件名
jobs_list = []

while 1:
    os.chdir(wait_directory)
    file_list = []
    for g09_file in os.listdir(wait_directory):
        if g09_file.endswith('.gjf'):
            file_list.append(g09_file)

    # ---------- debug ----------
    # if jobs_list:
    #     for job in jobs_list:
    #         output_file.write('  %s is running!' % job[2])
    # output_file.write('\n')
    # output_file.flush()

    # 两个列表都空了，执行完毕，程序退出
    if not jobs_list and not file_list:
        break
    # file_list空了，jobs_list没空，等待程序执行
    elif not file_list and jobs_list:
        time.sleep(interval)
        stop_run()
        cores_occupy_query()
        continue
    else:
        g09_file_run(file_list)
output_file.write("---------- All Tasks Finished! ----------\n")
output_file.close()

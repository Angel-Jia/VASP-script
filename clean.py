#!/usr/bin/env python
#clean up for VASP calculations

import sys
import os

def cleanup_main():
    os.system('rm *.out *chk')
    os.system('rm CHG CHGCAR EIGENVAL IBZKPT OSZICAR PCDAT vasprun.xml WAVECAR XDATCAR LOCPOT')
    os.system('gzip OUTCAR')
    return True

def cleanup_main_f():
    os.system('rm -f *.out')
    os.system('rm -f CHG CHGCAR EIGENVAL IBZKPT OSZICAR PCDAT vasprun.xml WAVECAR XDATCAR LOCPOT')
    os.system('gzip -f OUTCAR')
    return True

def ls_dir():
    tmp_list = os.listdir('.')
    dirs_list = []
    for i in tmp_list:
        if os.path.isdir(i):
            dirs_list.append(i)
    return dirs_list

def cleanup_recur(a):
    if a=='n':
        cleanup_main()
    elif a=='f':
        cleanup_main_f()
    dirs_list = ls_dir()
    for i in dirs_list:
        os.chdir(i)
        cleanup_recur(a)
        os.chdir('..')
    return True

def warn_disp():
    print "This script would clean up the result of the VASP calculations"
    print "The files CHG CHGCAR EIGENVAL IBZKPT OSZICAR PCDAT vasprun.xml WAVECAR XDATCAR will be deleted!"
    print "And the OUTCAR will be gzipped..."
    return None

def help_disp():
    warn_disp()
    print "to clean up the result of the current working directory, add '-c' argument"
    print "to perform a cleanup recursively, add '-R' arguement"
    print "add -f at the end of the argument list would cause forcible cleanup."

print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
print "%   CLEAN UP THE RESULT OF VASP CALCULATION    %"
print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
print "Ver 1.0, by the Computational Heterogeneous Catalysis Group\n at the Nankai University, Tianjin PR China"
print "April 2010"
print
print

if len(sys.argv) < 2:
    help_disp()
    sys.exit(0)

if sys.argv[1] == '-c':
    warn_disp()
    in_buf = raw_input('Are you sure? (y/n)')
    if in_buf == 'y':
        if len(sys.argv) < 3:
            cleanup_main()
        elif sys.argv[2]== '-f':
            cleanup_main_f()
    else:
        sys.exit(0)
elif sys.argv[1] == '-R':
    warn_disp()
    print "Recursive cleanup would perform cleanup on each of the subdirectory of the current working directory!"
    in_buf = raw_input('Are you sure? (y/n)')
    if in_buf == 'y':
        in_buf = raw_input('A lot of computational result might be LOST, are you serious? (y/n)')
        if in_buf == 'y':
            if len(sys.argv) < 3:
                cleanup_recur('n')
            elif sys.argv[2] == '-f':
                cleanup_recur('f')
        else:
            sys.exit(0)
    else:
        sys.exit(0)
else:
    print "Unidentifiable arguement!",sys.argv
    help_disp()
    sys.exit(0)

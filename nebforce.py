#!/usr/bin/env python
################################################################################
#      The tangential force analyzer for NEB calculation by VASP               #
################################################################################

#This script generates the tangential force profile for the NEB calculation by VASP
#This script is based on the work from the Computational Heterogeneous Catalysis group at the Nankai University
#writen by sky from Energy & Environmental Catalysis Research Group of Nankai University
#ver 1.0
#this is for the original VASP code
#this script can noly be used in python2.
#if you want to use it in python3, you only need to change grammar of "print" in the end of the script

import os
import sys
import subprocess


def die_out(a):
    print "Error occurred in "+a
    print "This may possibly due to the fact that the information had not been output by VASP yet."
    print "Please try later"
    sys.exit(1)


def readlist(tmp_file,list_name,field):
    try:
        in_buf = tmp_file.readline()
    except:
        die_out("reading and parsing the computational result.")
    if (len(in_buf)==0):
        die_out("reading and parsing the computational result.")
    tmp_file.seek(0)
    try:
        for in_buf in tmp_file.readlines():
            in_buf = in_buf.split()
            list_name.append(in_buf[field])
    except:
        die_out("reading and parsing the computational result.")

#welcome
print "********************************************************************************"
print "*      The tangential force analyzer for NEB calculation by VASP             *"
print "********************************************************************************"

print "by the Energy & Environmental Catalysis Research Group of Nankai University"
print "based on Energetic profile generator"
print "which comes from Computational Heterogeneous Catalysis group at the Nankai University"
print "Version 1.0"
print 
print


#get the number of image points
while True:
    in_buf=raw_input( "Please type in the number of image points in your simulation:")
    try:
        images=int(eval(in_buf))
        break
    except:
        print "Invalid value, type again!"
        continue

while True:
    in_filename=raw_input( "you need to creat a file to save information, please type in a file name:")
    try: 
        f=open(in_filename,'w')
        break
    except:
        print "failed to creat file, try again!"
        continue
        
#information acquisition
line_number = ['0']
energy_list = ['0']
tangential_list = ['0']

for i in xrange(1,(images+1),1):
    folder_name = "./%2.2d" % i
    try:
        os.chdir(folder_name)

        if os.path.isfile('OUTCAR'):
            print "OUTCAR successfully spotted in folder %2.2d." % i
            outcar_zipped = False
        elif os.path.isfile('OUTCAR.gz'):
            print "OUTCAR.gz successfully spotted. It would be unzipped temporarily in folder %2.2d." % i
            gunzip_outcar = subprocess.Popen(['gunzip','OUTCAR.gz'])
            gunzip_outcar.wait()
            outcar_zipped = True
        else:
            die_out('opening the file OUTCAR.')

        #creat energy list
        os.system("grep -n 'energy  without' OUTCAR > prof_tmp_ene_all")
        prof_tmp_ene_all = open("prof_tmp_ene_all",mode='r')
        energy_tmp_list = []
        readlist(prof_tmp_ene_all,energy_tmp_list,4)
        energy_list.append(energy_tmp_list)
        line_tmp_list = []
        prof_tmp_ene_all.seek(0)
        readlist(prof_tmp_ene_all,line_tmp_list,0)
        line_number.append(line_tmp_list)
        prof_tmp_ene_all.close()


        #reading the projections onto the tangent
        os.system("grep 'tangential force (eV/A)' OUTCAR >prof_tmp_tan_all")
        prof_tmp_tan_all = open('prof_tmp_tan_all',mode='r')
        tangential_tmp_list = []
        readlist(prof_tmp_tan_all,tangential_tmp_list,3)
        tangential_list.append(tangential_tmp_list)
        prof_tmp_tan_all.close()
        

        os.system("rm -f prof_tmp_*")

        if outcar_zipped:
            os.system("gzip OUTCAR")
            print "The file OUTCAR had been successfully gzipped back in folder %2.2d!" % i


        os.chdir("..")
    except:
        die_out("reading and parsing the result in folder %2.2d." % i)


#information output

min=10.0
min_index=0
min_distance=10
min_distance_index=0
n=len(line_number[1])
print >>f, "                       %.10s              %.10s" % ("energy","tangential")
print "                       %.10s              %.10s" % ("energy","tangential")
for i in xrange(0,n,1):
    print >>f, "steps:%d" % (i+1)
    print "steps:%d" % (i+1)
    for j in xrange(1,(images+1),1):
        print >>f, "folder%2.2d  %10s  %12.10f  %12.10s" % (j,line_number[j][i],eval(energy_list[j][i]),eval(tangential_list[j][i]))
        print "folder%2.2d  %10s  %12.10f  %12.10s" % (j,line_number[j][i],eval(energy_list[j][i]),eval(tangential_list[j][i]))
        if abs(float(tangential_list[j][i])-0) < min:
            min=abs(float(tangential_list[j][i]))
            min_index=i
    if float(tangential_list[1][i]) < 0 and float(tangential_list[images][i]) > 0:
        for j in xrange(1,(images+1),1):
            if float(tangential_list[j][i]) < 0 and float(tangential_list[j+1][i]) > 0 and (float(tangential_list[j+1][i]) - float(tangential_list[j][i])) < min_distance:
                min_distance=float(tangential_list[j+1][i]) - float(tangential_list[j][i])
                min_distance_index=i
                
    print >>f, ""
    print ""
print >>f, "The minimum tangential force is in steps:%d      The value is:%f" % (min_index+1,min)
print >>f, "Transition state may be in steps:%d              The value is:%f" % (min_distance_index+1,min_distance)
print "The minimum tangential force is in steps:%d      The value is:%f" % (min_index+1,min)
print "Transition state may be in steps:%d              The value is:%f" % (min_distance_index+1,min_distance)
f.close()
print ""
print "Result has been saved in", in_filename
print ""

#!/usr/bin/env python
################################################################################
#      The Energetic profile generator for NEB calculation by VASP             #
################################################################################

#This script generate the energetic profile for the NEB calculation by VASP
#This script is based on the script come from the Computational Heterogeneous Catalysis group at the Nankai University
#ver 1.0
#this is for the original VASP code

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
print "*      The Energetic profile generator for NEB calculation by VASP             *"
print "********************************************************************************"

print "by the Computational heterogenous catalysis group of the Nankai University"
print "Version 1.2"
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
print "Result:"
print "Reaction co-ordinate / Energy / Force par SPRING / Force perp REAL / Projection onto tangent (spring) / Projection onto tangent (REAL)"

min=10.0
min_index=0
n=len(line_number[1])
print "       %.10s  %.10s" % ("energy","tangential")
for i in xrange(0,n,1):
    print "steps:%d" % (i+1)
    for j in xrange(1,(images+1),1):
        print "folder%2.2d  %10s  %12.10f  %12.10s" % (j,line_number[j][i],eval(energy_list[j][i]),eval(tangential_list[j][i]))
        if abs(float(tangential_list[j][i])-0) < min:
            min=abs(float(tangential_list[j][i]))
            min_index=i
    print ""
print "The minimum tangential force is in steps:%d      The value is:%f" % (min_index+1,min)

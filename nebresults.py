#!/usr/bin/env python
################################################################################
#      The Energetic profile generator for NEB calculation by VASP             #
################################################################################

#This script generate the energetic profile for the NEB calculation by VASP
#by the Computational Heterogeneous Catalysis group at the Nankai University
#ver 1.2
#output of relavent forces added since Ver1.1
#capability of dealing with gzzipped outcar added since 1.2
#this is for the original VASP code

import os
import sys
import subprocess

class image_point:
    dis_to_prev = 0.0
    dis_to_next = 0.0
    energy = 0.0
    co_or = 0.0
    force_par_spring = 0.0
    force_perp_real = 0.0
    proj_spring = 0.0
    proj_real = 0.0

    def __init__(self,dtp, dtn, ener,force_par_spring,force_perp_real,proj_spring,proj_real):
        self.dis_to_prev = dtp
        self.dis_to_next = dtn
        self.energy = ener
        self.force_par_spring = force_par_spring
        self.force_perp_real = force_perp_real
        self.proj_spring = proj_spring
        self.proj_real = proj_real

    def outp(self):
        print "%10.6f  %15.10f  %5.5r  %5.5r  %5.5r  %10.6f" %(self.co_or,self.energy,self.force_par_spring,self.force_perp_real,self.proj_spring,self.proj_real)


def die_out(a):
    print "Error occurred in "+a
    print "This may possibly due to the fact that the information had not been output by VASP yet."
    print "Please try later"
    sys.exit(1)

def readvalue(tmp_file,field):
    try:
        in_buf = tmp_file.readline()
    except:
        die_out("reading and parsing the computational result.")
    if (len(in_buf)==0):
        die_out("reading and parsing the computational result.")
    tmp_file.seek(0)
    in_buf = in_buf.split()
    return eval(in_buf[field])



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
img_list=[image_point(0.0,0.0,0.0,0.0,0.0,0.0,0.0)]

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

        # read the image points distance.
        os.system("grep 'left and right image' OUTCAR | tail -1 > prof_tmp_dis")
        prof_tmp_dis = open("prof_tmp_dis",mode='r')
        dis_to_prev = readvalue(prof_tmp_dis,4)
        dis_to_next = readvalue(prof_tmp_dis,5)
        prof_tmp_dis.close()

        #read the energy
        os.system("grep 'energy  without' OUTCAR | tail -1 > prof_tmp_ene")
        prof_tmp_ene = open("prof_tmp_ene",mode='r')
        energy = readvalue(prof_tmp_ene,3)
        prof_tmp_ene.close()

        #reading the forces
        force_par_spring = 'N/A'
        force_perp_real = 'N/A'

        #reading the projections onto the tangent
        os.system("grep 'tangential force (eV/A)' OUTCAR | tail -1 > prof_tmp_tan")
        prof_tmp_tan = open('prof_tmp_tan',mode='r')
        proj_spring = 'N/A'
        proj_real = readvalue(prof_tmp_tan, 3)
        prof_tmp_tan.close()

        img_tmp = image_point(dis_to_prev ,dis_to_next , energy, force_par_spring, force_perp_real,proj_spring,proj_real)
        img_list.append(img_tmp)
        os.system("rm -f prof_tmp_*")

        if outcar_zipped:
            os.system("gzip OUTCAR")
            print "The file OUTCAR had been successfully gzipped back in folder %2.2d!" % i


        os.chdir("..")
    except:
        die_out("reading and parsing the result in folder %2.2d." % i)
img_list.append(image_point(0.0,0.0,0.0,0.0,0.0,0.0,0.0))



#co-ordination computation
coor_tmp=0.0
for i in xrange(1,images+1,1):
    coor_tmp += img_list[i].dis_to_prev
    img_list[i].co_or = coor_tmp
    continue
img_list[-1].co_or = img_list[-2].co_or + img_list[-2].dis_to_next




#information output
print "Result:"
print "Reaction co-ordinate / Energy / Force par SPRING / Force perp REAL / Projection onto tangent (spring) / Projection onto tangent (REAL)"

for i in img_list:
    i.outp()


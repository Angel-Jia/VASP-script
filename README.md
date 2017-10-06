# VASP-script
## 介绍
本仓库用于保存我在工作中经常用到的全部脚本文件,包括几个用于制作动画的脚本，对我工作帮助很大，现在共享出来供大家交流使用。部分脚本文件是在[vtst tool](http://theory.cm.utexas.edu/vtsttools/scripts.html)工具中提供的脚本上修改而来。编程语言主要为perl和shell script，含有少量python脚本。


## 使用方法
将所有脚本文件拷到本地用户目录文件夹~/bin中（没有则新建文件夹），然后执行`chmod +x ~/bin/*`添加权限。之后添加环境变量，在~/.bashrc中加入`export PATH=~/bin:$PATH`,保存后执行命令`source ~/.bashrc`即可使用。

## 主要脚本功能及用法详细介绍
注：没有介绍到的属于临时脚本，可不考虑,大部分的perl脚本在执行时如果不输入参数，将会给出简明用法，例如输入：
```
vas2gv.pl
```
则输出：
```
############### This script converts vasp file into gview file ###############
             ############ CONTCAR or POSCAR -> .gjf ############

Usage: vas2gv.pl file1 file2 file3.....
file can be POSCAR or CONTCAR and either direct or cartesian
Please try again!
```
-----
#### cel2pos.pl
用法：
```
cel2pos.pl file.cell
```
用于将materials studio的CASTEP模块生成的cell文件转化为VASP输入文件POSCAR，生成file.vasp文件

-----

#### ck
用法：
```
ck
```
在运行前用于检查参数的脚本，可检查K点的设置，POTCAR的赝势类型和POSCAR的前六行输入
如果执行该脚本的文件夹路径中含有关键字`dimer`,则还会检查是否有MODECAR存在

-----

#### cpfile
用法：
```
cpfile target_directory
```
把target_directory路径下的INCAR、POTCAR、KPOINTS以及所有的可执行文件拷贝到当前文件夹。
使用`-a`选项除了拷贝以上文件，还会将POSCAR拷贝到当前文件夹。

-----

#### dir2car.pl
用法：
```
dir2car.pl file1 file2 ...
```
将VASP的输入/输出文件从分数坐标转化为笛卡尔坐标，可一次性添加多个文件file1 file2 ....

-----

#### energy
用法：
```
energy dir1 dir2 ...
```
用于快速获取体系能量，会分别抓取文件夹dir1 dir2 ...中OUTCAR文件中的能量`energy without entropy`，并输出最后一个值。如果没有参数，则会输出当前文件夹下（包括子文件夹）所有的OUTCAR中的最后一个`energy without entropy`的值。

-----

#### excoor.pl
用法：
```
excoor.pl step1 step2 ...
```
该脚本会首先抓取OUTCAR文件中每一个离子步结束后体系的能量以及其中每个原子的坐标和受力情况，并在行末会计算出每个原子收到的xyz合力的大小，结果保存到OUTCAR.pos文件中。然后将第'step1'、'step2' ... 的坐标另存为POSCAR文件。
step1 step2 ... 是离子步的步数，可以省略。
例如执行命令`excoor.pl 10`，会生成一个OURCAR.pos文件，以及包含第10个离子步的POSCAR文件。

-----

#### chgflag.py
用法：
```
flachg.pl line1,line2,.... T/F vaspfile
```
line1、line2 ... 是需要改变驰豫标记的原子编号，POSCAR文件中的原子从上至下的编号依次是1，2，3，...，n。
例如执行命令`chgflag.py 2,5,10-13,22 F POSCAR`则会将POSCAR文件中第2个、第5个、第10-13个以及第22个原子的驰豫标记变为`F F F`

-----

#### freqmov.pl
用法：
```
freqmov.pl POSCAR freqfile 30 0.6
```
用于把频率计算的结果转化为动画。首先要制作freqfile文件,其格式为：
```
  30 f/i=   43.595023 THz   273.915607 2PiTHz 1454.173389 cm-1   180.294587 meV
             X         Y         Z           dx          dy          dz
     -1.334507  2.369499  6.388597    -0.015951    0.008861   -0.024862  
      2.621978  4.667179  6.419931    -0.008397   -0.017126   -0.024545  
      1.361682  2.515564  6.433748     0.010846    0.019286   -0.030780  
      2.704039  0.032985  6.442084     0.010923   -0.007642   -0.018801  
```
- freqfile中保存的是OUTCAR中的某一个振动频率**完整**的信息。1、2行必须有，之后是每个原子的坐标及其振动方向，原子的数量必须与本体系数量一致。例如30个原子的体系，就必须有32行数据，至于是不是虚频则无所谓。
- POSCAR是本体系的输入文件；
- 30是动画的帧数，数字越大动画越细腻，30足够了；
- 0.6是系数，用于调节振幅。OUTCAR中给出的振幅很大，需要适当缩减，0.6即可；

最后会产生一个freqfile.xyz文件，用VMD打开即可播放。
freqfile文件可用下列方法提取：
```
grep "20 f/i" OUTCAR -A 20 >freq20
```
`-A 20`是输出查找到的信息以及其后20行，命令的具体含义请自行百度。也可以自己打开OUTCAR，找到所需信息直接存为文本格式。

-----

#### gv2vas.pl
用法：
```
gv2vas.pl POSCAR file1.gjf  file2.gjf ...
```
把GaussianView生成的构型文件file.gjf转化为VASP的输入文件，以file1.vasp file2.vasp ...形式保存。生成VASP输入文件，其2-4行的坐标基以及原子弛豫标记将与POSCAR文件相同。元素种类和数量与gjf文件保持一致。
**重要：gjf文件中相同的元素必须相邻，用GaussianView画出的构型保存后将无法保证这一点，需要自行调整**

----

#### modemake.pl
用法：
```
modemake.pl freqfile 0.5
```
用于生成跑dimer所需要的MODECAR文件（VAPS需要与vtst tool一起编译），freqfile与之前的相同，0.5是系数，可以是负数，用于确定dimer的搜寻方向。正数则与freqfile中标识的振动方向相同，负数则相反。

----

#### moviecombine.pl
用法：
```
moviecombine.pl file1 file2 file3 ..... fileN output X Y Z
```
用于把多个xdat2xyz.pl生成的movie.xyz文件拼接到一起，可在NEB计算中实现多个镜像点按顺序排列的动画，方便找出过渡态。file1 file2 ....是.xyz文件，output是输出文件，可以VMD打开。X、Y、Z是设置偏移量。
例如计算一个2*3*4的立方超胞，设置了3个images,计算完成后在三个image的文件夹中分别执行`xdat2xyz.pl XDATCAR`生成各自的`movie.xyz`，并重行命名为`file1.xyz file2.xyz file3.xyz`,在该文件夹中执行：
```
moviecombine.pl file1.xyz file2.xyz file3.xyz out.xyz 2.0 0.0 0.0
```
`file1.xyz`中的所有原子坐标不变；
`file2.xyz`中的所有原子坐标将会加上(1*X,1*Y,1*Z),即统一在X轴方向加2;
`file3.xyz`中的所有原子坐标将会加上(2*X,2*Y,2*Z),即统一在X轴方向加4;
最后生成的`out.xyz`文件中，3个images将按照X轴的方向进行排列。
----

#### nebinfo
用法：
```
nebinfo
```
生成压缩包`NEBINFO.tar.gz`，其中包含三个文件夹`vaspfile`、`gvfile`、`movie`
`vaspfile` 包含每个像点的POSCAR和CONTCAR文件；
`gvfile` 包含每个像点的POSCAR和CONTCAR的gjf文件；
`movie` 包含了动画文件，把每个像点从起始构型到最终构型的POSCAR和CONTACR分别做成动画，用于计算前的构型检查；

----

#### nebmake.pl
用法：
```
nebmake.pl initail_image final_image num_image
```
vtst tool中自带的镜像生成脚本，在此基础上做了一些修改。如果final_image是分数坐标，则生成的像点文件都是分数坐标；如果final_image是笛卡尔坐标，则生成的像点文件都是笛卡尔坐标；

----

#### nebmovie
用法：
```
nebmovie X Y Z
```
把moviecombine.pl的繁琐操作合成为一个脚本。在含有POTCAR的文件夹中执行，将会进入到每一个像点文件夹生成movie.xyz，最后统一合成并压缩为一个名称movie.xyz的压缩包。

----

#### nebvtst.pl
用法：
```
nebvtst.pl num_images
```
会抓取NEB计算中每一个离子步中每个像点的能量，切线力以及需要弛豫的原子中受力最大的一个原子受到的力（即该力小于EDIFFG时计算会终止），列表输出，类似于这样：
```
steps: 1
images: 1    -151.68812    -0.27764     0.16389
images: 2    -151.54168    -0.70352     0.25647
images: 3    -151.28943    -0.85346     0.32021
images: 4    -150.97526    -1.15730     0.53053

steps: 2
images: 1    -151.68918    -0.26855     0.16441
images: 2    -151.54293    -0.70139     0.25001
images: 3    -151.29082    -0.90557     0.39795
images: 4    -150.97396    -1.11050     0.41420
```
结果太多时可重定向到另一个文件保存：
```
nebvtst.pl num_images > info
```

----

#### vas2cif.pl
用法：
```
vas2cif.pl file1 file2 ...
```
file是VASP的输入输出文件，坐标系不限。可转化为cif文件供materials studio打开。

----

#### vas2gv.pl
用法：
```
vas2gv.pl file1 file2 ...
```
file是VASP的输入输出文件，坐标系不限。可转化为gjf文件。

----

#### vas2xyz.pl
用法：
```
vas2xyz.pl file1 file2 ...
```
file是VASP的输入输出文件，坐标系不限。可转化为xyz文件。

----

#### xdat2xyz.pl
用法：
```
xdat2xyz.pl XDATCAR
```
vtst tool原生脚本，可以把XDATCAR转化为xyz文件。


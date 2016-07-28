# VASP-script
## 介绍
本仓库用于保存我在工作中经常用到的全部脚本文件，现在共享出来供大家交流使用。部分脚本文件是在[vtst tool](http://theory.cm.utexas.edu/vtsttools/scripts.html)工具中提供的脚本上修改而来。编程语言主要为perl和shell script，含有少量python脚本。

## 使用方法
将所有脚本文件拷到本地用户目录文件夹~/bin中（没有则新建文件夹），然后执行`chmod +x ~/bin/*`添加权限，之后添加环境变量，在~/.bashrc中加入`export PATH=~/bin:$PATH`,保存后执行命令`source ~/.bashrc`

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
####cel2pos.pl
用法：
```
cel2pos.pl file.cell
```
用于将materials studio的CASTEP模块生成的cell文件转化为VASP输入文件POSCAR，生成file.vasp文件

####check
用法：
```
check
```
在运行前用于检查参数的脚本，可检查K点的设置，POTCAR的赝势类型和POSCAR的前六行输入

####cpfile
用法：
```
cpfile dir
```
把dir路径下的INCAR、POTCAR、KPOINTS以及所有的可执行文件拷贝到当前文件夹

####dir2car.pl
用法：
```
dir2car.pl file1 file2 ...
```
将VASP的输入/输出文件从分数坐标转化为笛卡尔坐标，可一次性添加多个文件file1 file2 ....

####energy
用法：
```
energy dir1 dir2 ...
```
用于快速获取体系能量，会抓取文件夹dir1 dir2 ...中OUTCAR文件中的所有能量`energy without entropy`并分别输出最后一个值。如果没有参数，则会输出当前文件夹下（包括子文件夹）所有的OUTCAR中的最后一个`energy without entropy`的值。

####excoor.pl
用法：
```
excoor.pl file1 file2 ...
```
file必须是OUTCAR文件，该脚本会抓取其中每一个离子步结束后体系的能量以及其中每个原子的坐标和受力情况，并在行末会计算出每个原子收到的xyz合力的大小，结果保存到file.pos文件中。

####flachg.pl
用法：
```
flachg.pl modelfile vaspfile
```
用于将vaspfile中的原子弛豫标记T/F换成modefile中的原子弛豫标记，结果将覆盖vaspfile。两个文件都必须是标准VASP输入输出文件，且原子数量必须相同。modefile仅采用其原子弛豫标记T/F。可用于连续地计算，比如固定一部分原子进行计算，完成之后再固定另外一部分原子进行下一步计算。



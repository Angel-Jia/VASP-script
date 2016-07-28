# VASP-script
## 介绍
本仓库用于保存我在工作中经常用到的全部脚本文件，现在共享出来供大家交流使用。部分脚本文件是在[vtst tool](http://theory.cm.utexas.edu/vtsttools/scripts.html)工具中提供的脚本上修改而来。编程语言主要为perl和shell script，含有少量python脚本。

## 使用方法
将所有脚本文件拷到本地用户目录文件夹~/bin中（没有则新建文件夹），然后执行`chmod +x ~/bin/*`添加权限，之后添加环境变量，在~/.bashrc中加入`export PATH=~/bin:$PATH`,保存后执行命令`source ~/.bashrc`

## 主要脚本功能及用法详细介绍（没有介绍到的属于临时脚本，可不考虑）
大部分的perl脚本在执行时如果不输入参数，将会给出简明用法，例如输入：
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


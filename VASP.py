import re
import subprocess


def read_total_atoms():
    pipe = subprocess.Popen("sed -n '7p' POSCAR", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (content, error) = (pipe.stdout.read().strip(), pipe.stderr.read())
    if content != "":
        space = re.compile(r'\s+')
        content = space.split(content)
        number = 0
        for num in content:
            number += int(num)
        return number

    if error != "":
        print ""
        print "POSCAR: No such file or incorrect"
        number = raw_input("please input the total number of atoms:")
        number = number.strip()
        if number == "" or re.search(r'[^0-9]', number) is not None:
            print ""
            print "incorrect number!"
            print ""
            exit(0)
        return int(number)



def grep_OUTCAR(command):
    pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (content, error) = (pipe.stdout.readlines(), pipe.stderr.read())
    if not content:
        return content

    if error != "":
        print ""
        print "POSCAR: No such file"
        print ""
        exit(0)

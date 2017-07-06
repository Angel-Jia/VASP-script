import re
import os


def read_total_atoms():
    space = re.compile(r'\s+')
    atoms = space.split(os.system("sed -n '7p' POSCAR").read().strip())

    if re.search(r'[^0-9]', atoms[0]) is not None:
        print "POSCAR: No such file or incorrect"
        number = raw_input("please input the total number of atoms:")
        number = number.strip()
        if number == "" or number == re.search(r'[^0-9]') is not None:
            print "incorrect number!"
            exit(0)
        return int(number)
    number = 0
    for num in atoms:
        number += int(num)
    return number


def grep_OUTCAR(command):
    content = os.popen(command).readlines()
    if re.search(r'No such file', content[0]) is not None:
        print "POSCAR: No such file"
        exit(0)
    return content

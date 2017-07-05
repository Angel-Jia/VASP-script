import re
import os


def read_total_atoms():
    space = re.compile(r'\s+')
    atoms = space.split(os.popen("sed -n '7p' POSCAR").read().strip())

    if re.search(r'[a-z]', atoms[0]) is not None:
        print "POSCAR: No such file or incorrect"
        number = raw_input("please input the total number of atoms:")
        number = number.strip()

        if number == "":
            exit(0)
        elif re.search(r'[^0-9]', number) is not None:
            print "incorrect number!"
            exit(0)

        return int(number)


def grep_OUTCAR(command, write_file_name = ''):
    if write_file_name == '':
        content = os.popen(command).readlines()
        if re.search(r'No such file', content[0]) is not None:
            print "POSCAR: No such file"
            exit(0)
        return content
    else:
        command += " > %s" % write_file_name
        os.popen(command)
        result = os.popen("cat %s |head -1" % write_file_name).readline()
        if re.search(r'No such file', result) is not None:
            print "POSCAR: No such file"
            exit(0)

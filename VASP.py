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


def grep_outcar(command):
    pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (content, error) = (pipe.stdout.readlines(), pipe.stderr.read())
    if content:
        return content

    if error != "":
        print ""
        print "POSCAR: No such file"
        print ""
        exit(0)
    return []


# this function can only read file in VASP 5.0 or later
def read_poscar(file_name):
    space = re.compile(r'\s+')
    with open(file_name) as input_file:
        content = input_file.readlines()

        lattice = float(content[1].strip())

        basis = []
        for i in xrange(2, 5):
            line = space.split(content[i].strip())
            basis.append([float(line[0]), float(line[1]), float(line[2])])

        elements = space.split(content[5].strip())
        num_atoms = space.split(content[6].strip())
        for i in xrange(0, len(num_atoms)):
            num_atoms[i] = int(num_atoms[i])

        index = 0
        if re.search(r'^[Ss]', content[7]) is None:
            selectiveflag = ''
            index = 7
        else:
            selectiveflag = content[7].strip()
            index = 8

        if re.search(r'^[Dd]', content[index]) is None:
            coordinate_type = 'Cartesian'
        else:
            coordinate_type = 'Direct'

        coordinates = []
        selective = []
        start = index + 1
        end = start + sum(num_atoms)
        if selectiveflag == '':
            for i in xrange(start, end):
                line = space.split(content[i].strip())
                coordinates.append([float(line[0]), float(line[1]), float(line[2])])
        else:
            for i in xrange(start, end):
                line = space.split(content[i].strip())
                coordinates.append([float(line[0]), float(line[1]), float(line[2])])
                if len(line) == 6:
                    selective.append([line[3], line[4], line[5]])
                else:
                    selective.append(['', '', ''])

    if re.search(r'^[Cc]', coordinate_type) is None:
        coordinate_type = 'Cartesian'
        coordinates = dirkar(basis, coordinates)

    return lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective


def write_poscar(file_name, lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective):
    with open(file_name, 'w') as output_file:
        description = ""
        for atom in elements:
            description += "%s  " % atom
        output_file.write(description.rstrip() + '\n')
        output_file.write("  %15.10f\n" % lattice)
        for i in xrange(0, 3):
            output_file.write("  %15.10f  %15.10f  %15.10f\n" % (basis[i][0], basis[i][1], basis[i][2]))
        output_file.write(description.rstrip() + '\n')
        num_atom = ''
        for num in num_atoms:
            num_atom += "%d  " % num
        output_file.write(num_atom.rstrip() + '\n')
        if selectiveflag != '':
            output_file.write(selectiveflag + '\n')
        output_file.write(coordinate_type + '\n')

        if re.search(r'^[Dd]', coordinate_type):
            coordinates = kardir(basis, coordinates)

        # keeping dimension the same
        if len(coordinates) - len(selective) > 0:
            for i in xrange(len(selective), len(coordinates)):
                selective.append(['', '', ''])

        for i in xrange(0, len(coordinates)):
            output_file.write("%16.10f  %16.10f  %16.10f %s %s %s\n" % (coordinates[i][0], coordinates[i][1], coordinates[i][2],
                                                                      selective[i][0], selective[i][1], selective[i][2]))


def dirkar(basis, coordinates):
    for i in xrange(0, len(coordinates)):
        v1 = coordinates[i][0] * basis[0][0] + coordinates[i][1] * basis[1][0] + coordinates[i][2] * basis[2][0]
        v2 = coordinates[i][0] * basis[0][1] + coordinates[i][1] * basis[1][1] + coordinates[i][2] * basis[2][1]
        v3 = coordinates[i][0] * basis[0][2] + coordinates[i][1] * basis[1][2] + coordinates[i][2] * basis[2][2]
        coordinates[i][0] = v1
        coordinates[i][1] = v2
        coordinates[i][2] = v3
    return coordinates


def kardir(basis, coordinates):
    inverse = [[basis[1][1]*basis[2][2]-basis[2][1]*basis[1][2], basis[2][1]*basis[0][2]-basis[0][1]*basis[2][2], basis[0][1]*basis[1][2]-basis[1][1]*basis[0][2]],
               [basis[2][0]*basis[1][2]-basis[1][0]*basis[2][2], basis[0][0]*basis[2][2]-basis[2][0]*basis[0][2], basis[1][0]*basis[0][2]-basis[0][0]*basis[1][2]],
               [basis[1][0]*basis[2][1]-basis[2][0]*basis[1][1], basis[2][0]*basis[0][1]-basis[0][0]*basis[2][1], basis[0][0]*basis[1][1]-basis[1][0]*basis[0][1]]]
    omega = basis[0][0]*basis[1][1]*basis[2][2] + basis[0][1]*basis[1][2]*basis[2][0] + basis[0][2]*basis[1][0]*basis[2][1] - \
            basis[0][2]*basis[1][1]*basis[2][0] + basis[1][2]*basis[2][1]*basis[0][0] + basis[2][2]*basis[0][1]*basis[1][0]

    inverse = [[inverse[0][0]/omega, inverse[0][1]/omega, inverse[0][2]/omega],
               [inverse[1][0]/omega, inverse[1][1]/omega, inverse[1][2]/omega],
               [inverse[2][0]/omega, inverse[2][1]/omega, inverse[2][2]/omega]]

    for i in xrange(0, len(coordinates)):
        v1 = coordinates[i][0] * inverse[0][0] + coordinates[i][1] * inverse[1][0] + coordinates[i][2] * inverse[2][0]
        v2 = coordinates[i][0] * inverse[0][1] + coordinates[i][1] * inverse[1][1] + coordinates[i][2] * inverse[2][1]
        v3 = coordinates[i][0] * inverse[0][2] + coordinates[i][1] * inverse[1][2] + coordinates[i][2] * inverse[2][2]

        # move atoms to primative cell
        coordinates[i][0] = v1 + 60 - int(v1 + 60)
        coordinates[i][1] = v2 + 60 - int(v2 + 60)
        coordinates[i][2] = v3 + 60 - int(v3 + 60)
    return coordinates


def read_gjf(file_name):
    begin = re.compile(r'^[0-9]+\s+[0-9]+$')
    space = re.compile(r'\s+')
    content = []

    with open(file_name) as input_file:
        content = input_file.readlines()
    index = 4
    while index < len(content):
        if begin.search(content[index].strip()) is not None:
            index += 1
            break
        index += 1

    elements = []
    num_atoms = []
    coordinates = []
    atoms = 0

    while index < len(content):
        line = space.split(content[index].strip())
        coordinates.append([float(line[1]), float(line[2]), float(line[3])])
        if elements and elements[-1] == line[0]:
            atoms += 1
        elif elements and elements[-1] != line[0]:
            elements.append(line[0])
            num_atoms.append(atoms)
            atoms = 1
        else:
            elements.append(line[0])
            atoms = 1
        index += 1
    num_atoms.append(atoms - 1)

    return elements, num_atoms, coordinates


def write_gif(file_name, elements, num_atoms, coordinates):
    with open(file_name, 'w') as output_file:
        output_file.write("# opt freq b3lyp/6-31g\n\n")
        output_file.write("creat from vasp file\n\n")
        output_file.write("0 1\n")
        total_index = 0
        for element_id in range(0, len(elements)):
            element_index = 0
            while element_index < num_atoms[element_id]:
                output_file.write("%2s    %16.10f    %16.10f    %16.10f\n" %
                      (elements[element_id], coordinates[total_index][0], coordinates[total_index][1], coordinates[total_index][2]))
                element_index += 1
                total_index += 1

        output_file.write("\n\n")

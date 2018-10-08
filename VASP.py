import re
import subprocess
# 注意：所有函数读取的坐标统一为笛卡尔坐标


class CmdRrror(Exception):
    def __init__(self, errorinfo):
        super().__init__(self)  # 初始化父类
        self.errorinfo = errorinfo

    def __str__(self):
        return 'Command Execution Error: ' + self.errorinfo


def execCmd(command):
    pipe = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (content, error) = (pipe.stdout.readlines(), pipe.stderr.read().decode())
    if content:
        for i in range(len(content)):
            content[i] = content[i].decode()
        return content

    if error != "":
        raise CmdRrror(error)


# this function can only read file in VASP 5.0 or later
def readVasp(file_name):
    """
    :param file_name:
    :return: [lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective]
    lattice: scale, float
    basis: [x1, y1, z1], [x2, y2, z2], [x3, y3, z3]], float
    elements: [element1, element2, ...], str
    num_atoms: [number_of_element1, number_of_element2, ...], int
    selectiveflag: 'Selective dynamics' or '', str
    coordinate_type: 'Cartesian', str
    coordinates: [[x1, y1, z1], [x2, y2, z2], ...], float
    selective: [[T/F, T/F, T/F], [T/F, T/F, T/F], ...], str
    """
    space = re.compile(r'\s+')
    with open(file_name) as input_file:
        content = input_file.readlines()

    lattice = float(content[1].strip())

    basis = []
    for i in range(2, 5):
        line = space.split(content[i].strip())
        basis.append([float(line[0]), float(line[1]), float(line[2])])

    elements = space.split(content[5].strip())
    num_atoms = list(map(int, space.split(content[6].strip())))

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
        for i in range(start, end):
            line = space.split(content[i].strip())
            coordinates.append([float(line[0]), float(line[1]), float(line[2])])
    else:
        for i in range(start, end):
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


def writeVasp(file_name, lattice, basis, elements, num_atoms, selectiveflag, coordinate_type, coordinates, selective):
    """
    :param file_name: str
    :param lattice: float
    :param basis: [x1, y1, z1], [x2, y2, z2], [x3, y3, z3]], float
    :param elements: element1, element2, element3], str
    :param num_atoms: [number_of_element1, number_of_element2, ...], int
    :param selectiveflag: 'Selective dynamics' or '', str
    :param coordinate_type: 'Cartesian' or 'Direct', str
    :param coordinates: [[x1, y1, z1], [x2, y2, z2], ...], float
    :param selective: [[T/F, T/F, T/F], [T/F, T/F, T/F], ...] or [], str
    :return:
    """
    with open(file_name, 'w') as output_file:
        description = ' '.join(elements)
        output_file.write('%s\n' % description)
        output_file.write("  %15.10f\n" % lattice)
        for i in range(0, 3):
            output_file.write("  %15.10f  %15.10f  %15.10f\n" % (basis[i][0], basis[i][1], basis[i][2]))
        output_file.write(description.rstrip() + '\n')

        num_atom = ' '.join(list(map(str, num_atoms)))
        output_file.write('%s\n' % num_atom)

        if selectiveflag != '':
            output_file.write('%s\n' % selectiveflag)
        output_file.write('%s\n' % coordinate_type)

        if re.search(r'^[Dd]', coordinate_type):
            coordinates = kardir(basis, coordinates)

        # keeping dimension the same
        if len(coordinates) - len(selective) > 0:
            for i in range(len(selective), len(coordinates)):
                selective.append(['', '', ''])

        for i in range(0, len(coordinates)):
            output_file.write("%16.10f  %16.10f  %16.10f %s %s %s\n" % (coordinates[i][0], coordinates[i][1], coordinates[i][2],
                                                                      selective[i][0], selective[i][1], selective[i][2]))


def readGjf(file_name):
    """
    :param file_name: str
    :return: [elements, num_atoms, coordinates]
    elements: [element1, element2, ...], str
    num_atoms: [number_of_element1, number_of_element2, ...], int
    coordinates: [[x1, y1, z1], [x2, y2, z2], ...], float
    """
    # 搜索自旋数值
    begin = re.compile(r'^[0-9]+\s+[0-9]+$')
    space = re.compile(r'\s+')

    with open(file_name) as input_file:
        content = input_file.readlines()
    index = 4
    # 找到自旋值之后下一行开始为原子坐标
    while index < len(content):
        if begin.search(content[index].strip()) is not None:
            index += 1
            break
        index += 1

    elements = ['']
    num_atoms = []
    coordinates = []

    while index < len(content):
        line = content[index].strip()
        if line == '':
            break

        # line: [元素符号, x, y, z]
        line = space.split(line)
        coordinates.append([float(line[1]), float(line[2]), float(line[3])])
        if elements[-1] == line[0]:
            num_atoms[-1] += 1
        elif elements[-1] != line[0]:
            elements.append(line[0])
            num_atoms.append(1)
        index += 1

    return elements[1:], num_atoms, coordinates


def writeGjf(file_name, elements, num_atoms, coordinates):
    """
    :param file_name: str
    :param elements: [element1, element2, ...], str
    :param num_atoms: [number_of_element1, number_of_element2, ...], int
    :param coordinates: [[x1, y1, z1], [x2, y2, z2], ...], float
    :return:
    """
    with open(file_name, 'w') as output_file:
        output_file.write("# opt freq b3lyp/6-31g\n\n")
        output_file.write("creat from vasp file\n\n")
        output_file.write("0 1\n")
        total_index = 0
        for element_id, element in enumerate(elements):
            for element_index in range(num_atoms[element_id]):
                output_file.write("%2s    %16.10f    %16.10f    %16.10f\n" %
                                  (element, coordinates[total_index][0], coordinates[total_index][1],
                                   coordinates[total_index][2]))
                total_index += 1

        output_file.write("\n\n")


def readCell(file_name):
    """
    把Materials Studio生成的cell文件转换成vasp文件
    :param file_name: str
    :return: [basis, elements, num_atoms, coordinates]
    basis: [x1, y1, z1], [x2, y2, z2], [x3, y3, z3]], float
    elements: [element1, element2, ...], str
    num_atoms: [number_of_element1, number_of_element2, ...], int
    coordinates: [[x1, y1, z1], [x2, y2, z2], ...], float
    """
    space = re.compile(r'\s+')
    with open(file_name, 'r') as cell_file:
        content = cell_file.readlines()

    basis = []
    for i in range(1, 4):
        basis.append(list(map(float, space.split(content[i].strip()))))

    index = 7
    elements = ['']
    num_atoms = []
    coordinates = []

    while index < len(content):
        line = content[index].strip()
        if line.startswith('%'):
            break

        line = space.split(line)
        coordinates.append([float(line[1]), float(line[2]), float(line[3])])
        if elements[-1] == line[0]:
            num_atoms[-1] += 1
        elif elements[-1] != line[0]:
            elements.append(line[0])
            num_atoms.append(1)
        index += 1

    coordinate_type = 'Cartesian'
    coordinates = dirkar(basis, coordinates)

    return basis, elements[1:], num_atoms, coordinate_type, coordinates


def readXYZ(file_name):
    """
    :param file_name: str
    :return: [num_structures, elements, num_atoms, coordinates]
    num_structures: number of structures in xyz file, int
    elements: [element1, element2, ...], str
    num_atoms: [number_of_element1, number_of_element2, ...], int
    coordinates: [[x1, y1, z1], [x2, y2, z2], ...], float
    """
    num_structures = 0
    elements = ['']
    num_atoms = []
    coordinates = []

    space = re.compile(r'\s+')

    with open(file_name, 'r') as xyz_file:
        content = xyz_file.readlines()

    total_atoms = int(content[0].strip())
    index = 2
    while index < len(content):
        if content[index].strip() == '':
            break
        num_structures += 1
        max_line = index + total_atoms
        while index < max_line:
            line = space.split(content[index].strip())
            coordinates.append([float(line[1]), float(line[2]), float(line[3])])
            if num_structures == 1:
                if elements[-1] == line[0]:
                    num_atoms[-1] += 1
                elif elements[-1] != line[0]:
                    elements.append(line[0])
                    num_atoms.append(1)
            index += 1
        index += 2
    return num_structures, elements[1:], num_atoms, coordinates


def writeXYZ(file_name, num_structures, elements, num_atoms, coordinates):
    """
    :param num_structures: number of structures in xyz file, int
    :param elements: [element1, element2, ...], str
    :param num_atoms: [number_of_element1, number_of_element2, ...], int
    :param coordinates: [[x1, y1, z1], [x2, y2, z2], ...], float
    :return:
    """
    total_atoms = sum(num_atoms)
    index = 0
    with open(file_name, 'w') as output_file:
        while num_structures != 0:
            output_file.write('%d\n' % total_atoms)
            output_file.write('create form python\n')
            for element_id, element in enumerate(elements):
                for element_index in range(num_atoms[element_id]):
                    output_file.write("%2s    %16.10f    %16.10f    %16.10f\n" %
                                      (element, coordinates[index][0], coordinates[index][1],
                                       coordinates[index][2]))
                    index += 1
            num_structures -= 1


def dirkar(basis, coordinates):
    for i in range(0, len(coordinates)):
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

    for i in range(0, len(coordinates)):
        v1 = coordinates[i][0] * inverse[0][0] + coordinates[i][1] * inverse[1][0] + coordinates[i][2] * inverse[2][0]
        v2 = coordinates[i][0] * inverse[0][1] + coordinates[i][1] * inverse[1][1] + coordinates[i][2] * inverse[2][1]
        v3 = coordinates[i][0] * inverse[0][2] + coordinates[i][1] * inverse[1][2] + coordinates[i][2] * inverse[2][2]

        # move atoms to primative cell
        coordinates[i][0] = v1 + 60 - int(v1 + 60)
        coordinates[i][1] = v2 + 60 - int(v2 + 60)
        coordinates[i][2] = v3 + 60 - int(v3 + 60)
    return coordinates

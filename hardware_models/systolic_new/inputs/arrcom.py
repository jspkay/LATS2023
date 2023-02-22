#!/usr/bin/python3

import sys
import numpy as np

if len(sys.argv) < 2:
	print("Error! no file to parse!")

for file in sys.argv[1:]:
	print("Parsing {}".format(file), end="...")

	fin = open(file, "r")
	input_array = fin.read()
	fin.close()

	[m1, m2] = input_array.split("x")

	M = np.zeros([2, 4, 4])

	k = 0
	for m in [m1, m2]:
		#print(m)
		i = 0
		j = 0
		rows = m.split(";")
		for r in rows:
			els = r.replace("[", "").replace("]","").split(" ")
			for e in els:
				if e == '':
					continue
				#print(e, end=" ")
				M[k][i][j] = int(e)
				j = j + 1
			#print("-")
			i = i + 1
			assert(j == 4)
			j = 0
		k = k +1
		#print(k)
		assert(i == 4)
		i = 0

	#print(M)
	


indices_R1 = [(1,4), (1,3), (1,2), (1,1), (0,0), (0,0), (0,0), (0,0), (0,0), (0,0)]
indices_R2 = [(0,0), (2,4), (2,3), (2,2), (2,1), (0,0), (0,0), (0,0), (0,0), (0,0)]
indices_R3 = [(0,0), (0,0), (3,4), (3,3), (3,2), (3,1), (0,0), (0,0), (0,0), (0,0)]
indices_R4 = [(0,0), (0,0), (0,0), (4,4), (4,3), (4,2), (4,1), (0,0), (0,0), (0,0)]

indices = [indices_R1, indices_R2, indices_R3, indices_R4]


def getStringFromMatrix(m, first):
	if first:
		t = 0
		p = 1
	else:
		t = 1
		p = 0
	s = ""
	for i in range(0,4):
		s += "{"
		for j in range(0, 10):
			r = indices[i][j][t]
			c = indices[i][j][p]
			if c == 0: # 0 in r or c means that this position of the vector should have 0 value
				s += '0'
			else:
				value = int(m[r-1][c-1])
				if value < 0:
					s += "-10#"+str(-value)
				else:
					s += "10#"+str(value)
			s += " "

		s += "}\n"
	return s


s1 = getStringFromMatrix(M[0], True)
s2 = getStringFromMatrix(M[1], False)

fout = open("{}.com".format(file), "w")
fout.write(s1)
fout.write(s2)
fout.close()

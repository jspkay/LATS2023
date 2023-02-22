#!/usr/bin/python3

import png
import sys

print(sys.argv)
if len(sys.argv) < 2:
    print("Error! Not enough argument!")
    print("Usage: ./decompressOutput.py file1 [file2 file3...]")
    exit(1)

indexes = [0, 1, 2, 3]

for file in sys.argv[1:]:
    _, _, img, _ = png.Reader(file).read()

    f = open(file+".dek", "w")

    arr = []
    for value in img:
        for b in value:
            halfBit = '{:02X}'.format(b)
            arr.append(halfBit)
            if len(arr) == 4:
                ccc = arr[indexes[0]] + arr[indexes[1]] + arr[indexes[2]] + arr[indexes[3]]
                f.write(ccc+" ")
                arr = []
        f.write("\n")

    f.close()

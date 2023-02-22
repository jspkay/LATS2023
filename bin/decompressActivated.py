#!/usr/bin/python3

import png
import sys

print(sys.argv)
if len(sys.argv) < 2:
    print("Error! Not enough argument!")
    print("Usage: ./decompressActivated.py file1 [file2 file3...]")
    exit(1)

for file in sys.argv[1:]:
    _, _, img, _ = png.Reader(file).read()

    f = open(file+".dek", "w")

    byte = ''
    for value in img:
        for b in value:
            halfBit = '{:02X}'.format(b)
            f.write(halfBit+" ")
        f.write("\n")

    f.close()

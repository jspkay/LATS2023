#!/usr/bin/python3

import png
import sys

# MSB to LSB
indexes = [0, 1, 2, 3]

if len(sys.argv) < 2:
    print("Error! No input file given!")
    exit(1)

for file in sys.argv[1:]:
    if file.split(".")[-1].lower() == "png":
        print("Skipping {}".format(file))
        continue

    print("Processing {}...".format(file), end="")

    f = open(file)
    content = f.read()
   
    rows = content.count("\n")
    cols = content.split("\n")[0].count(" ")

    rowN = 0
    img = []
    for r in content.split("\n")[:-1]:
        if len(r) == 0:
            continue
        img.append([])
        for c in r.split(" ")[:-1]:
            ccc = [0, 0, 0, 0]
            ccc[indexes[0]] = int(c[0:2], base=16)
            ccc[indexes[1]] = int(c[2:4], base=16)
            ccc[indexes[2]] = int(c[4:6], base=16)
            ccc[indexes[3]] = int(c[6:], base=16)
            img[rowN].extend(ccc)
        rowN += 1

    pngImg = png.from_array(img, "RGBA")
    #print(pngImg.info)

    fileName = '.'.join(file.split(".")[:-1])
    if len(fileName) == 0:
        fileName = file
    pngImg.save(fileName + ".png")

    print("Done")

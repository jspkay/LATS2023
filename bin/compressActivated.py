#!/usr/bin/python3

import png
import sys

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

    img = []
    for r in content.split("\n")[:-1]:
        rr = [int(i, base=16) for i in r.split(" ")[:-1]]
        if len(rr) == 0:
            continue
        img.append(rr)

    pngImg = png.from_array(img, "L")
    #print(pngImg.info)

    fileName = '.'.join(file.split(".")[:-1])
    pngImg.save(fileName + ".png")

    print("Done")

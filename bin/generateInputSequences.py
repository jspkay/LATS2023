#!/usr/bin/python3

from pprint import pprint
import struct
import argparse
import os

parser = argparse.ArgumentParser(prog="generateInputSequences.py",
                                description="generate the input sequences for a convolutional channel")
parser.add_argument("inputFile")
parser.add_argument("-r", "--rows", required=True) # array size 
parser.add_argument("-c", "--columns", required=True)
parser.add_argument("-k", "--kernel-height", default=5, required=False) # kernel size
parser.add_argument("-j", "--kernel-width", default=5, required=False)
parser.add_argument("-o", "--output-dir", required=True)
parser.add_argument("-z", "--zeros", required=False, default=3)
parser.add_argument("-s", "--old-style", action="store_true", help="Whether to use old style naming, i.e. the first sequence is named as HW_SIM_MAIN_SEQ.DAT instead of using the index")

args = parser.parse_args()
print(args)

outdir = args.output_dir

if not os.path.exists(outdir):
    print("Path '{}' does not exist. Make it first.".format(outdir))
    exit(1)

######################### Image read.
f = open(args.inputFile, "rb")

magicBytes = f.read(2)
print(magicBytes)
if magicBytes != b'P5':
    print("invalid file format.")
    exit(1)
f.read(1) # single whitespace

width_string = ""
tmp = f.read(1).decode("ASCII")
while not tmp.isspace():
    width_string += tmp
    tmp = f.read(1)
    tmp = tmp.decode("ASCII")
width = int(width_string)
print("Input width is: " + str(width) )

height_string = ""
tmp = f.read(1).decode("ASCII")
while not tmp.isspace():
    height_string += tmp
    tmp = f.read(1)
    tmp = tmp.decode("ASCII")
height = int(height_string)
print("Input height is: " + str(height) )

maxval_string = ""
tmp = f.read(1).decode("ASCII")
while not tmp.isspace():
    maxval_string += tmp
    tmp = f.read(1)
    tmp = tmp.decode("ASCII")
maxval = int(maxval_string)
print("maxval is: " + str(maxval))

twoByte=False
if maxval < 256:
    print("Only one byte per value")
else:
    twoByte=True

img = []
col = []
for r in range(height):
    for c in range(width):
        if not twoByte:
            v = struct.unpack("b", f.read(1))[0]
        else:
            bbb = f.read(2)
            v = struct.unpack("<h", bbb)[0]
        col.append(v)
    img.append(col)
    col = []

#### Needed data: 
# height, width -> INPUT image size
# kerH, kerW -> kernel size
# outH, outW -> OUTPUT image size
# arrH, arrW -> physical array size

############## Frame start
arrH = int(args.rows)
arrW = int(args.columns)

kerH = int(args.kernel_height)
kerW = int(args.kernel_width) 

outH = height - kerH + 1
outW = width - kerW + 1

frame_starts = [ (0,0) ] # first convolution is always in the top-right corner
i = 0; j = 0
# Each starting point correspond to the corner of each convolution.
# Since there are outH convolutions (at least horizontally) that is the limit
while j < outH:
    while i + arrW < outW:
        i += arrW
        frame_starts.append( (j,i) )
    i = -arrW
    j += arrH
pprint(frame_starts)

############# OUTPUT

def getSingleSequence(img, startX, startY, kerH, kerW):
    res = []
    for i in range(kerW):
        for k in range(kerH):
            res.append(img[startX+k][startY+i])
    return res

def getCompleteSequence(img, fs, offset, nZ, ks, columns):
    res = []
    global height, width
    kerH, kerW = ks
    hh = kerH
    ww = columns+kerW-1
    for x, y in fs:
        if x+offset+hh >= height:
            hh = height-x-offset
        if y+ww >= width:
            ww = width-y
        res.extend( getSingleSequence(img, x+offset, y, hh, ww) )
        res.extend([0]*nZ)
    return res

########### OUTPUT
nZ = int(args.zeros)
for i in range(arrH): # for each column of the physical array
    s = getCompleteSequence(img, frame_starts, i, nZ, (kerH, kerW), arrW)
    if args.old_style and i==0:
        f = open(outdir + "/HW_SIM_MAIN_SEQ.DAT", "w")
    else:
        f = open(outdir+ "/HW_SIM_SEQ_{}.DAT".format(i+1), "w")
    out = "" 
    for el in s:
        out += "{}\n".format(el)
    f.write(out)
    f.close()
    #pprint(s)

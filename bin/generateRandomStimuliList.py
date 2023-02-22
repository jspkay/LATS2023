#!/usr/bin/python3

import argparse
import sqlite3 as sql 
import random

parser = argparse.ArgumentParser(prog="generateRandomStimuliList.py",
    description="generate a list of random stimuli from the MNIST handwritten dataset")

parser.add_argument("stimuliDirectory")
parser.add_argument("-i", "--input-database", required=True)
parser.add_argument("-k", "--samples-per-class", default=10) # number of samples per class
parser.add_argument("-o", "--output-file", default="stimuli.list")
parser.add_argument("-s", "--seed", required=True) # seed for experiment repetition
parser.add_argument("--id-only", action="store_false")

args = parser.parse_args()

k = int(args.samples_per_class)
dbFile = args.input_database
outFile = args.output_file
if outFile[-1] == '/':
    outfile = outFile[:-1]

mainDir = args.stimuliDirectory
if mainDir[-1] == '/':
    mainDir = mainDir[:-1]

f = open(outFile, "w")
conn = sql.connect(dbFile, isolation_level="EXCLUSIVE")
c = conn.cursor()
random.seed(args.seed)
for i in range(10): # for each class of digit
    a = []
    for row in c.execute("select id from stimuli where label = " + str(i)):
        a.append(row[0])
    rnd = random.sample(a, k=k)
    for s in rnd:
        if args.id_only:
            res = "{0}/env{1:0>4}.pgm\n".format(mainDir, s)
        else:
            res = "{0:0>4}\n".format(s)
        f.write(res)
f.close()


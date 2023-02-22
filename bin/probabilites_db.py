#!/usr/bin/python3

import os
from pprint import pprint
from tqdm import tqdm
import sqlite3 as sql
import sys

if len(sys.argv) < 2:
    print("Usage: ./probabilities_db.py probDirectory")
    exit(1)

dts = sys.argv[1]

table = []
filelist = os.listdir(dts)
for i in tqdm(range(len(filelist)), ascii=True, desc="Listing files..."):
	file = filelist[i]
	stimulus = file.replace("env", "")
#	print(stimulus)
	path = os.path.join(dts, file)
	if os.path.isdir(path):
		for file in os.listdir(path):
			newPath = os.path.join(path, file)
			
			fault_id = file
			try:
				f = open(newPath+"/probabilities.txt")
			except:
				continue;
			probabilities = f.readline()
			probs = probabilities.split(" ")
			
			table.append((stimulus, fault_id, probs[0], probs[1], probs[2], probs[3], probs[4], probs[5], probs[6], probs[7], probs[8], probs[9]))

#pprint(table)

conn = sql.connect("my.db", isolation_level="EXCLUSIVE")
c = conn.cursor()

try:
    c.execute("drop table injections")
except:
    print("No table was dropped")

c.execute("""create table injections(
		stimulus_id integer not null, 
		fault_id integer not null, 
		prob0 integer, 
		prob1 integer, 
		prob2 integer, 
		prob3 integer, 
		prob4 integer, 
		prob5 integer, 
		prob6 integer, 
		prob7 integer, 
		prob8 integer, 
		prob9 integer,
		primary key(stimulus_id, fault_id))""" )

c.executemany("insert into injections values(?, ?, ?,?,?,?,?,?,?,?,?,?)", table)

c.execute("select * from injections")
print(c.fetchall())

print("Ok?")
a = input()
if a == "y":
	conn.commit()
conn.close()


#!/usr/bin/python3

import sqlite3 as sql
import os
import pprint

# Read all faults
faults = []
for file in os.listdir("faults"):
	filename = os.path.join("faults", file)
	f=open(filename)
	line = f.readline()
	#print(line)
	f.close()
	id = file.split("_")[1]
	path = line.split("freeze ")[1].split(" ")[0]

	channel = path.split("channels_generate(")[1][0]
	p1 = path.split("result(")[1].split(",")[0]
	p2 = path.split("result(")[1].split(",")[1].split(")")[0]
	bit = path.split("(")[-1].split(")")[0]
	print(bit)

	value = line.split("freeze ")[1].split(" ")[1].replace(";\n", "");
	faults.append((id, channel, 1, p1, p2, bit, value));

pprint.pprint(faults)

# Create file and connection
conn = sql.connect("my.db")
c = conn.cursor()

# Create table
c.execute("drop table faults")
c.execute("create table faults(id integer, channel integer, type integer, p1 integer, p2 integer, bit integer, value integer)")

#Insert values
c.executemany("insert into faults values(?, ?, ?, ?, ?, ?, ?)", faults)


# Check insertion
c.execute("SELECT * from faults")
print(c.fetchall())

print("Ok? [y/N]", end=" ")
a = input()
if a == "y":
	conn.commit()

conn.close()

#!/usr/bin/python3

import sqlite3
import os
from pprint import pprint

table = []

maindir="SEQUENCES_GOLD"
for file in os.listdir(maindir):
    stimulus = file.replace("env", "")
    path = os.path.join(maindir, file)
    if os.path.isdir(path):
        fn = os.path.join(path, "probabilities.txt")
        f = open(fn)
        probs = f.readline()
        f.close()
        probs = probs.split(" ")
        
        table.append((stimulus, probs[0], probs[1],probs[2], probs[3], probs[4], probs[5], probs[6], probs[7], probs[8], probs[9]))

pprint(table)

input()

conn = sqlite3.connect("gold.db", isolation_level="EXCLUSIVE")
c = conn.cursor()
c.execute("""create table gold(stimulus integer primary key, 
                prob0 integer, 
    prob1 integer, 
    prob2 integer, 
    prob3 integer, 
    prob4 integer, 
    prob5 integer, 
    prob6 integer, 
    prob7 integer, 
    prob8 integer, 
    prob9 integer) """)
c.executemany("insert into gold values(?, ?,?,?,?,?,?,?,?,?,?)", table)

c.execute("select * from gold")
print(c.fetchall())
print("ok?")
a = input()
if a == 'y':
    conn.commit()
conn.close()


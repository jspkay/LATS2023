#!/usr/bin/python3

import zipfile
import os
from tqdm import tqdm
import sqlite3 as sql
import sys
from pprint import pprint

if len(sys.argv) < 2:
    print("Usage: differences_db.py mainDirectory")
    exit(1)


conn = sql.connect("my.db", isolation_level="EXCLUSIVE")
c = conn.cursor()

try:
    c.execute("drop table differences")
except:
    print("No table dropped!")

c.execute("""create table differences(
        stimulus_id integer not null,
        fault_id integer not null,
        type varchar(255),
        row integer not null,
        col integer not null,
        golden_value varchar(100),
        faulty_value varchar(100),
        primary key(stimulus_id, fault_id, type, row, col) ) """)

fileList = list(os.walk( sys.argv[1] ))

table = []

for dirpath, dirnames, filenames in tqdm(fileList):
    if len(dirnames) == 0:

        splitted = dirpath.split("/")
        
        try:
            faultID = int(splitted[-1])
            stimID = int(splitted[-2].replace("env", ""))
        except:
            #print("The directory {} is not part of the scope...".format(dirpath) )
            continue

        for file in filenames:
            if "differences" in file:
                #print("Processing {}".format(file))

                #print("\nThe file contains:")
                archive = zipfile.ZipFile(os.path.join(dirpath,file), "r")
                for el in archive.namelist():
                    #print("processing " + el + "...")

                    if 'ACTIVATED' in el:
                        recordType = "activated"
                    if 'OUTPUT' in el:
                        recordType = "output"

                    content = archive.open(el).read().decode("ASCII")
                    if "=D" in content:
                        #print("No differences, skipping...")
                        continue

                    lines = content.split("\n")
                    #print(lines)
                    
                    for l in lines:
                        if len(l) == 0:
                            continue
                        goldValue = l.split(" | ")[0].split("! ")[1]
                        #print("Correct: " + goldValue)

                        pppp = l.split(" | ")[1].split(" ")
                        faultyValue = pppp[0]
                        #print("Faulty: " + faultyValue)

                        row = pppp[1].replace("(", "")
                        col = pppp[2].replace(")", "")
                        #print("Pos: {} {}". format(row, col))

                        table.append((stimID, faultID, recordType, row, col, goldValue, faultyValue))
                archive.close()


            else:
                pass
                #print("Skipping {}...".format(file))


pprint(table)
c.executemany("insert into differences values(?, ?, ?, ?, ?, ?, ?)", table)
conn.commit()

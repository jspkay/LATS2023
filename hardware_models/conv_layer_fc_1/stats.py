#!/bin/python3

from pprint import pprint
import sqlite3 as sql
import matplotlib.pyplot as plt

def arrayEquals(a1, a2):
    if len(a1) != len(a2):
        return False
    else:
        for i in range(len(a1)):
            if a1[i] != a2[i]:
                return False
    return True

mydb_c = sql.connect("my.db")
mydb_c.row_factory = sql.Row
mydb = mydb_c.cursor()
gold_c = sql.connect("data/gold.db")
gold = gold_c.cursor()

### Preliminary data
# vertial value faults barchart
mydb.execute("select p1 from faults")
row = mydb.fetchone()[0]
faultDepths = {}
while row is not None:
    if row in faultDepths:
        faultDepths[row] += 1
    else:
        faultDepths.update({row : 1})

    row = mydb.fetchone()
    if row is not None:
        row = row[0]
pprint(faultDepths)
plt.bar(faultDepths.keys(), faultDepths.values())
plt.show()

### Statistics variables
# masked, good, accept, warning, critical
safety = [0, 0, 0, 0, 0]
# safety per channel. It is a dictionary devided by 
safetyPerChannel = [{},{},{},{},{}]
channelsTot = [0 for i in range(6)]
# vertical depth safety (only accept, warning and critical)
vertSafety = {2: {}, 3: {}, 4: {}}

total = 0
mydb.execute("select * from faults as f, injections as i where i.fault_id=f.id order by stimulus_id")
# Order is id, channel, type, p1, p2, bit, value, stimulus_id, fault_id, probs...
row = mydb.fetchone()

#Indeces
rowKeys = row.keys()
probs_start_index = rowKeys.index("prob0")
channel_index = rowKeys.index("channel")
fault_index = rowKeys.index("fault_id")
stimulus_index = rowKeys.index("stimulus_id")
rowP_index = rowKeys.index("p1")
colP_index = rowKeys.index("p2")
bit_index = rowKeys.index("bit")

row = tuple(row)
gold_stim = -1
while row is not None:
    stimulus = row[stimulus_index]
    fault  = row[fault_index]
    probs = row[probs_start_index:probs_start_index+10]
    channel = row[channel_index]
    rowP = row[rowP_index]
    colP = row[colP_index]
    bit = row[bit_index]
    
    total = total + 1
    if stimulus != gold_stim:
        gold.execute("select * from gold where stimulus = {}".format(stimulus))
        grow = gold.fetchone()
        [gold_stim, gold_probs] = [grow[0], grow[1:]]
        gold_pred = max(gold_probs)
        gold_label =  gold_probs.index(gold_pred)

    pred = max(probs)
    pred_label = probs.index(pred)

    # Masked
    if arrayEquals(probs, gold_probs):
        ftype = 0
    elif pred >= gold_pred and gold_label == pred_label: # good
        ftype = 1
    elif gold_label == pred_label and abs(pred-gold_pred)/gold_pred >= .05: # accept
        ftype = 2
    elif gold_label == pred_label: # warning
        ftype = 3
    else: # critical
        ftype = 4

    # General safety
    safety[ftype] += 1
    # Channel related
    if channel in safetyPerChannel:
        safetyPerChannel[ftype][channel] += 1
    else:
        safetyPerChannel[ftype].update({channel: 1})
    channelsTot[channel-1] += 1
    #Vertical depth safety
    if ftype >=2:
        if rowP in vertSafety[ftype]:
           vertSafety[ftype][rowP] += 1
        else:
            vertSafety[ftype].update({rowP : 1})


    row = mydb.fetchone()
    if row is not None:
        row = tuple(row)

#####Normalization

#General
perc = [s / total for s in safety]
print("Masked: {:.3f}\ngood: {:.3f}\naccept: {:.3f}\nwarning: {:.3f}\ncritical: {:.3f}\n".format(perc[0], perc[1], perc[2], perc[3], perc[4]))

# Per Channel
for i in range(len(safetyPerChannel)):
    tmp = dict(map(lambda el: (el[0], el[1]/safety[i]), safetyPerChannel[i].items()))
    safetyPerChannel[i] = tmp
pprint(safetyPerChannel)

# Vertical
pprint(vertSafety)
plt.bar(vertSafety[2].keys(), vertSafety[2].values())
plt.show() 
        

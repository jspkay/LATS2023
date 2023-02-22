#!/bin/bash

names=(alpha bravo charlie delta echo foxtrot golf hotel india juliett kilo lima mike november oscar papa quebec romeo sierra tango uniform victor whiskey xray yankee zulu)

parallelSimulation=10 # between 1 and 26. extend names if you want more

let parallelSimulation=$parallelSimulation-1
for i in $(seq 0 $parallelSimulation)
do
	el=${names[$i]}
	echo "Processing work_$el..."
	./configure.sh "work_$el" > /dev/null 2>&1
done

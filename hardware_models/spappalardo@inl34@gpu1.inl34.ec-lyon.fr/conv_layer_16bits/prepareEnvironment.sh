#!/bin/bash

echo "This completely clean the gathered data. Are you sure?"
read

echo "Extremely sure???"
read

names=(alpha bravo charlie delta echo foxtrot golf hotel india juliett kilo lima mike november oscar papa quebec romeo sierra tango uniform victor whiskey xray yankee zulu)

parallelSimulation=$1 # between 1 and 26. extend names if you want more

rm work_* -r

let parallelSimulation=$parallelSimulation-1
for i in $(seq 0 $parallelSimulation)
do
	el=${names[$i]}
	echo "Processing work_$el..."
	./configure.sh "work_$el" > /dev/null 2>&1
done

echo "There is still time, but it's your last chance."

rm faults/fault_*
rm -r queue
ficID=$(cat ficID)
rm FAULTY_$ficID -r

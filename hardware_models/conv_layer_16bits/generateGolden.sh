#!/bin/bash

printprogress() {
	total=$(tput cols)
	let total=$total-20
	let p=$n*100/$len
	let t=$p*$total/100
	printf "\r["
	for i in $(seq 1 $t)
	do printf "#"
	done
	for l in $(seq $i $total)
	do printf " "
	done
	printf "] $p%% ($n/$len)"

}

n=0
len=10000
for el in $(ls data/stimuli_16/)
do
	stimID=$(echo $el | cut -d'.' -f1)
	if [ ! -d data/SEQUENCES_GOLD_16/$stimID ] 
	then
		mkdir data/SEQUENCES_GOLD_16/$stimID
	fi
	newName=$(printf "data/stimuli_16/env%04d.pgm" $n)
	data/n2d2_test_16 $newName --save-first-layer-output data/SEQUENCES_GOLD_16/$stimID --only-first-layer > /dev/null 2>&1
	printprogress
	let n=$n+1
done
printprogress
echo ""
exit 0

#!/bin/bash

list=$(ls SEQUENCES_GOLD)
maindir=SEQUENCES_GOLD
for dir in $list
do
	for i in {1..6}
	do
		./sources/activate ./$maindir/$dir/OUTPUT_$i ./$maindir/$dir/ACAC_$i
		sub ./$maindir/$dir/ACTIVATED_$i ./$maindir/$dir/ACAC_$i >/dev/null 2>&1
		if [ $? -ne 0 ]
		then 
			echo "ERROR! $dir $i"
			exit 2
		fi
	done
	echo $dir
done

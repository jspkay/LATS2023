#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: ./propagateFirstLayer.sh probabilityVectorOutputName"
	exit 1
fi

echo "starting..."

basedir="."
firstLayerData=$(find ./FAULTY_1 -iname "HW_SIM_ACTIVATED_1.DAT")
length=$(echo "$firstLayerData" | wc -l)
outName=$1

a=1
for input in $firstLayerData
do
	a=$(echo "$a+1" | bc )
	dir=$(dirname $input)
	if test $(echo "$a % 100" | bc) == 0
	then
		printf "$(echo "$a/$length" | bc -l)%%\r"
	fi

	#printf "Running n2d2_test with first layer files in $dir..."
	./data/n2d2_test ./data/dummy.pgm --first-layer-from-file $dir --save-prob-vector "$dir/$outName" > /dev/null 2>&1
	#printf "Ok\n"
done

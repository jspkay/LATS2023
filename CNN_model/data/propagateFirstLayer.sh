#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: ./propagateFirstLayer.sh probabilityVectorOutputName"
	exit 1
fi

basedir="."
firstLayerData=$(find -iname "HW_SIM_ACTIVATED_1.DAT")
outName=$1

for input in $firstLayerData
do
	dir=$(dirname $input)
	printf "Running n2d2_test with first layer files in $dir..."
	./n2d2_test dummy.pgm --first-layer-from-file $dir --save-prob-vector "$dir/$outName" > /dev/null 2>&1
	printf "Ok\n"
done

#!/bin/bash

basedir="."
stimuli=$(cat "${basedir}/stimuli.list")

for f in $stimuli
do
	filename=$(basename "${f%.*}")
	outDir="${basedir}/SEQUENCES_GOLD/$filename"
	if [ -d "$outDir" ]
	then
		echo -n "Directory $filename already exists. Checking for file..."
		if [ -e "$outDir/HW_SIM_MAIN_SEQ.DAT" ]
		then
			echo "File exists, skipping!"
			continue;
		fi
	else
		printf "Processing $filename. Mkdir..."
		mkdir $outDir
	fi

	printf "OK. Running n2d2_test..."

	./n2d2_test "${basedir}/$f" --only-first-layer --save-first-layer-input $outDir --save-first-layer-output $outDir 2>/dev/null 1>&2
	if [[ $? -ne 0 ]]
	then
		printf "\b\b Something went wrong during the execution of n2d2_test!!!\nEXITING!\n"
		exit 1
	fi

	printf "OK.\n"
done

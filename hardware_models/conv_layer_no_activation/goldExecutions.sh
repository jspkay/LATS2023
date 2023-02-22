#!/bin/sh


basedir="data"
stimuli=$(cat "${basedir}/stimuli.list")
simDir="${basedir}/HW_SIM_FILES"

if [ ! -e "$simDir/WEIGHTS_1.DAT" ]
then
	echo -n "File $basedir/HW_SIM_FILES/WEIGHTS_1.DAT doesn't exist! Generating weights..." 
	./${basedir}/n2d2_test $basedir/dummy.pgm  --only-first-layer --save-weights $simDir > /dev/null 2>&1
	printf "OK. Starting the script...\n"
fi

for f in $stimuli
do
	filename=$(basename "${f%.*}")
	outDir="${basedir}/SEQUENCES_GOLD/$filename"
	if [ ! -e "$outDir/HW_SIM_MAIN_SEQ.DAT" ]
	then
		echo "File $filename/HW_SIM_MAIN_SEQ.DAT doesn't exist! Run n2d2_test first!"
		continue;
	fi
	
	if [ -e "$outDir/HW_SIM_OUTPUT_1.DAT" ]
	then
		echo "Image $filename already processed! Skipping..."
		continue;
	fi

	printf "Processing $filename. Copying files..."
	cp ${outDir}/* $simDir
	printf "OK. Running hardware simulation..."
	res=$(vsim -c work.tb -voptargs="+acc -novopt" -do "run 2.5 us; q")
	echo $res | grep "Errors: 0" > /dev/null
	if [[ $? -ne 0 ]]
	then
		echo "$res"
		exit 2
	fi
	printf "OK. "
	mv ${simDir}/HW_SIM* $outDir
	printf "Generating report... "
	diffs=0
	for i in {1..6} # number of channels of the first layer
	do
		sub "${basedir}/SEQUENCES_GOLD/${filename}/OUTPUT_${i}" "$basedir/SEQUENCES_GOLD/${filename}/HW_SIM_OUTPUT_${i}.DAT" > "$basedir/SEQUENCES_GOLD/$filename/differences_OUTPUT_$i.txt"
		printf "%d " $?
		sub "${basedir}/SEQUENCES_GOLD/${filename}/ACTIVATED_${i}" "$basedir/SEQUENCES_GOLD/${filename}/HW_SIM_ACTIVATED_${i}.DAT" > "$basedir/SEQUENCES_GOLD/$filename/differences_ACTIVATED_$i.txt"
		printf "%d " $?
	done
	printf "Done.\n"
done



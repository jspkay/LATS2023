#!/bin/bash


if [[ $# -ne 3 ]]
then
	echo "Error! Call the program like this: ./simulate <nanoseconds> <input_file> <fault_list>"
	echo "Where <input_file> represent a vsim compatible format indicating the input values for the matrices which go into the systolic array"
	echo "And <fault_list> is a file containing a vsim compatible format with the commands for the signals to inject the faults (might be an empty file for a golden simulation)"
	exit -1
fi

file=$2

rm -r work/

vcom basic_element.vhd
vcom systolic_generic.vhd
vcom systolic_generic_tb.vhd

# Matrices input for the simulation
NEWLINE=$'\n'
changed_values=""
lines=(A B)
n_inputs=4
kk=0
for line in ${!lines[@]}
do
	for i in $(seq 1 $n_inputs)
	do
		let j=i+kk
		input=$(head $file -n $j | tail -n1)
		s="change ${lines[$line]}($i)  $input; "
		changed_values="$changed_values${NEWLINE}$s"
	done
	let kk=kk+4
done

forced=1

forced_values=$(cat $3) 

cmd="
	vcd file outputs/report;
	vcd add -r /systolic_tb/*;
	log -r /*;

	$changed_values;
	$forced_values;

	run $1 ns;
	vcd flush;
	log -flush;
	quit;"

echo $cmd

vsim -c work.systolic_tb -do "$cmd" -voptargs="+acc"

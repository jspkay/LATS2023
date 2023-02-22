#!/bin/bash


if [[ $# -ne 3 ]]
then
	echo "Error! Call the program like this: ./simulate <nanoseconds> <input_file> <fault_list>"
	echo "Where <input_file> represent a vsim compatible format indicating the input values for the matrices which go into the systolic array"
	echo "And <fault_list> is a file containing a vsim compatible format with the commands for the signals to inject the faults (might be an empty file for a golden simulation)"
	exit -1
fi

file=$2

vcom basic_element.vhd
vcom systolic_array.vhd
vcom systolic_tb.vhd

# Matrices input for the simulation
NEWLINE=$'\n'
changed_values=""
input_lines=(A1 A2 A3 A4 B1 B2 B3 B4)
for i in ${!input_lines[@]}
do
	let j=i+1
	input=$(head $file -n $j | tail -n1)
	s="change ${input_lines[$i]} $input; "
	changed_values="$changed_values${NEWLINE}$s"
done

forced=1

forced_values=$(cat $3) 

cmd="
	vcd file outputs/report;
	vcd add -r /systolic_tb/*;

	$changed_values;
	$forced_values;

	run $1 ns;
	vcd flush;
	quit;"

echo $cmd

vsim -c work.systolic_tb -do "$cmd" -voptargs="+acc"

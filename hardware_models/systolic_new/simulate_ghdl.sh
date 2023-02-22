#!/bin/bash

ghdl --clean
rm work*

# Change inputs
#flag=0
#while read -r line
#do
#	if [[ $(echo $line | grep "### START STRING" ) && flag -eq 0 ]]
#	then
#		echo Started!
#		flag=1
#	fi
#	
#	if [[ $flag -ne 0 ]]
#	then
#		echo "$flag  => {1 1 1 1 1 1 1 1 1 1}" >> work.systolic_tb_tmp.vhd
#		flag=$(expr $flag + 1)
#	fi
#
#	if [[ $(echo $line | grep "### STOP STRING") && flag -ne 0 ]]
#	then
#		echo "Finish"
#		flag=0
#	fi
#
#	if [[ flag -eq 0 ]]
#	then
#		echo $line >> work.systolic_tb_tmp.vhd
#	fi
#
#done < "systolic_generic_tb.vhd";
#
#exit 0

ghdl -a --time-resolution=ns -fsynopsys ./basic_element.vhd
ghdl -a --time-resolution=ns -fsynopsys ./systolic_generic.vhd 
ghdl -a --time-resolution=ns -fsynopsys ./systolic_generic_tb.vhd

ghdl -e --time-resolution=ns -fsynopsys P
ghdl -e --time-resolution=ns -fsynopsys systolic_tb 

ghdl -r --time-resolution=ns -fsynopsys systolic_tb --stop-time=99ns --wave=wave.ghw   
gtkwave wave.ghw > /dev/null 2>&1 &




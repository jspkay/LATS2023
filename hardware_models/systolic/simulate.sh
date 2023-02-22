#!/bin/bash

vcom basic_element.vhd
vcom systolic_array.vhd
vcom systolic_tb.vhd

vsim -c work.systolic_tb -do "
	vcd file report;
	vcd add /systolic_tb/*; 
	vcd add /systolic_tb/M/P12/*; 
	vcd add /systolic_tb/M/P13/*;
	vcd add /systolic_tb/M/P42/*;
	vcd add /systolic_tb/M/P43/*;
	vcd add /systolic_tb/M/P44/*;
	vcd add /systolic_tb/M/P22/*;
	vcd add /systolic_tb/M/P21/*;
	run 100 ns; 
	vcd flush; 
	quit" \
	-voptargs="+acc"

#!/bin/bash

rm -r work

vcom basic_element.vhd
vcom systolic_generic.vhd
vcom systolic_generic_tb.vhd

vsim -c work.systolic_tb -do "
	vcd file report;
	vcd add -r /systolic_tb/*;
	vcd add /systolic_tb/*
	vcd add /systolic_tb/m_sig;
	vcd add /systolic_tb/f_sig;
	vcd add /systolic_tb/p_sig;
	vcd add /systolic_tb/r_in;
	vcd add /systolic_tb/c_in;	

	change A(1) {12 42 12 42 0 0 0 0 0 0}

	run 100 ns; 
	vcd flush; 
	quit" \
	-voptargs="+acc"

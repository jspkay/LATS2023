#!/bin/bash
vcom basic_element.vhd -2008
vcom basic_element_tb.vhd -2008

#vsim -c work.basic_tb -do runSim.tcl -voptargs="+acc"

vsim -c work.basic_tb -do "vcd file report; vcd add /basic_tb/*; vcd add /basic_tb/P1/*; run 56 ns; vcd flush; quit" -voptargs="+acc"

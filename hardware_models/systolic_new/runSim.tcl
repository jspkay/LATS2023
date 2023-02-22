#!/urs/bin/tclsh
vcd file report
vcd add /basic_tb/*
vcd add /basic_tb/P1/*
run 56 ns
vcd flush
quit

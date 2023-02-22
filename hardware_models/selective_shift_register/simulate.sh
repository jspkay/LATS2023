vsim -c work.tb -do "log -r /*; run 1 us; log -flush; quit" -voptargs="+acc";

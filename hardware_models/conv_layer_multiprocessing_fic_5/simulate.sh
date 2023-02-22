if [[ $# -lt 2 ]]
then
	echo "Usage ./simulate.sh LIBRARY  TIME [UNIT]"
	printf "\t TIME - represents the time to simulate\n"
	printf "\t UNIT - time unit for the simulation (ps, ns, us, ms). Default is ns\n"
	exit 1
fi

LIBRARY=$1

TIME=$2
if [[ $# -eq 3 ]]
then
	UNIT=$3
else
	UNIT="ns"
fi

res=$(vcom -2008 ./*.vhd)
echo $res | grep "Errors: 0" > /dev/null;

if [[ $? -ne 0 ]]
then
	echo "$res"
	exit 1
fi

vsim -c $LIBRARY.tb -voptargs="+acc" -do "log -r /*; run $TIME $UNIT; log -flush; q";


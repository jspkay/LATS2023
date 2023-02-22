#!/bin/bash

list=$(find -iname "HW_SIM_ACTIVATED*.DAT" -or -iname "HW_SIM_OUTPUT*.DAT")
for el in $list
do
	echo $el | grep ACTIVATED > /dev/null
	if [[ $? -eq 0 ]]
	then
		compressActivated.py $el
	fi

	echo $el | grep OUTPUT > /dev/null
	if [[ $? -eq 0 ]]
	then 
		compressOutput.py $el
	fi

	rm $el
done

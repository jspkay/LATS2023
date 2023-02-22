#!/bin/bash

vmap thesis ../thesis_lib/work

echo "";


if [[ $# -eq 0 ]]
then
	initial=$(cat additional_components)
	declare -A component_list
	for i in ${initial[@]}
	do
		component_list[$i]=1;
		if test -f ../$i/additional_components
		then
			others=$(cat ../$i/additional_components)
			for line in ${others[@]}
			do
				component_list[$line]=1;
			done
		fi
	done
elif [[ $# -eq 1 ]]
then
	declare -A component_list
	component_list[$1]=1;
fi


for i in ${!component_list[@]}
do
	echo -n "Compiling $i... "
	res=$(vcom -2008 ../$i/$i.vhd)
	echo "$res" | grep "Errors: 0" > /dev/null;
	if [[ $? -eq 0 ]]
	then
		echo "OK";
	else 	
		echo "";
		echo "";
		echo "$res";
		echo "";
	fi;
done

#!/bin/bash

vmap thesis ../thesis_lib/work

echo "";

if [[ $# -eq 0 ]]
then
	workDir="work"
else
	workDir=$1
fi

# Clean the work dir
rm -r $workDir

# Populate the component list
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

# compile additional components
for i in ${!component_list[@]}
do
	echo -n "Compiling $i... "
	res=$(vcom -work $workDir -2008 ../$i/$i.vhd)
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

#change dir name
template=$(ls ./*.vhd.template) # There should be just one
awk -v workDir=$workDir '{sub("work", workDir, $0); print}' $template > "${template%.*}"
mkdir -p $workDir/HW_SIM_FILES/

# compile these components
res=$(vcom -work $workDir -2008 ./*.vhd)
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

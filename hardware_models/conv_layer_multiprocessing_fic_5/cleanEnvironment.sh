#!/bin/bash

echo "This completely clean the gathered data. Are you sure?"
read

echo "Extremely sure???"
read

rm work_* -r
rm faults/fault_*
rm -r queue
ficID=$(cat ficID)
rm FAULTY_$ficID -r

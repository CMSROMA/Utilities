#!/bin/bash

crab_file=$1

if [ ! -e "crab_copy.cfg" ]; then
    if [ -r "$crab_file" ]; then
	dataset=`grep datasetpath $crab_file`
	echo $dataset
	sed "s|^datasetpath.*=.*$|$dataset|" ~/tool/crab_copy.cfg > ./crab_copy.cfg
    fi
fi


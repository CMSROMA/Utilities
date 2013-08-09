#!/bin/bash

usage(){
    echo "`basename $0` file.root"
}

case $# in 
    1)
	;;
    *)
	echo -n "Error. "
	usage
	exit 1
	;;
esac

root -l -b -q $1 /home/tesi/data/bin/root2eps.C

mv root2eps_result.eps "`dirname $1`/`basename $1 .root`.eps"


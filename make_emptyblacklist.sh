#!/bin/bash

min_dim=0.0045

#==============================
usage(){
    echo "usage: `basename $0`" > /dev/stderr
}

case $# in 
    1)
	dir=$1;
	;;
    *)
	usage
	exit 1
	;;
esac
#==============================

# il \$ serve per non prendere variabili di shell quando si usano le
# virgolette doppie " 
rfdir.sh $dir | \
    awk "(\$5 < $min_dim){print \$10}" | \
    sed "s|^|$dir|"



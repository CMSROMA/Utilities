#!/bin/bash

usage(){
    echo "Usage: `basename $0` file" > /dev/stderr
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

file=$1

n_chain=10
num_chain=`cat $file | wc -l`

i_chain=0
echo "i_chain = $i_chain"
echo "num_chain = $num_chain"

while (( $i_chain < $num_chain )) ; do
    let max_chain=$i_chain+$n_chain
    if [ "$i_chain" != "0" ];then
	list=`sed "1,$i_chain d" $file | head -$n_chain | sed 's|rfio:||; s|^$||'` #>> ./filelist/$sample/$sample-$n.list
	rootfile_test.sh $list &
    else
	list=`head -$n_chain $file | sed 's|^$||'` 
	rootfile_test.sh $list & 
    fi
    let i_chain=$i_chain+$n_chain
done



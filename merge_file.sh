#!/bin/bash
# merging script
# it merges file appending each line of the second file to the
# corrisponding line of the second one 

usage(){
    echo "usage: `basename $0` file1 file2 ..." > /dev/stderr
}
# 

# the number of parameters must be equal to the number of files you
# want to merge (not minus to 2)

case $# in 
    0)
	usage
	exit 1
	;;
    1)
	echo "you are merging just one file" > /dev/stderr
	cat $1; exit 0;
#	echo "Error -> Wrong number of parameters." > /dev/stderr;
#	echo "         Usage: merge_file.sh file1 file2 file3 ..." > /dev/stderr;
#	exit 1
	;;
    *)
	;;
esac

# mettere un controllo se il file esiste

#touch /tmp/merge_file.tmp
#TMP_FILE

# per ora rimuovo il file su cui poi dovro' scrivere
if [ -e merge_file.tmp ]; then
    rm merge_file.tmp
fi


for i in $@ 
  do

    # muovo l'output nel temporaneo di cui fare il merge
 
    if [ ! -e merge_file.tmp ]; then # necessario!
    	cp $i merge_file.tmp
    else 
	mv merge_file.tmp /tmp/merge_file.tmp
	awk -f $HOME'/awk/merge.awk' -v FILE=/tmp/merge_file.tmp $i \
	    > merge_file.tmp
    fi
#echo $i
done

exit 0
# cosi' lo script e' autoconsistente
# ma sono sicura che si puo' fare di meglio
cat merge_file.tmp
rm merge_file.tmp 

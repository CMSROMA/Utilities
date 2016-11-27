#!/bin/bash


usage(){
    echo "Usage: `basename $0` sample|file" > /dev/stderr
}

case $# in 
    1)
	;;
    *)
	usage
	exit 1
	;;
esac

if [ -r "$1" ] ;then
    file=$1
    sample="file"
else
    sample=$1
    file=filelist/$sample.list
fi

if [ ! -e "$file" ]; then
    echo "Filelist corresponding to $sample not found" > /dev/stderr
    exit 1
fi

isCrab=`head -1 $file | awk '{if(match($0,"_[0-9]*_[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]\.root")){print 0}}'` 
if [ "$isCrab" != "0" ]; then
    echo "[WARNING `basename $0`] $file not a file produced by crab. Filelist not sorted" >> /dev/stderr
    exit 2;
fi


# separatore
FS="_"
# indice del job
index=`head -1 $file | awk -F $FS '(NF!=0){print NF-2}'`

sort -t $FS -k $index -n $file > $file.crabsort
mv $file.crabsort $file

exit 0

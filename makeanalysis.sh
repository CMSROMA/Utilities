#!/bin/bash
# Author: Shervin
# Version: 1.0
# Date: 19-01-2010

info(){
    echo "Script that creats an analysis evironment" > /dev/stderr
}
usage(){
    echo "Usage: `basename $0` AnalysisName [subAnalysis_level]" > /dev/stderr
}

case $# in 
    1)
	proj=$1
	subLevel=0
	;;
    2)
	proj=$1
	subLevel=$2
	;;
    *)
	echo -n "Error. " > /dev/stderr
	usage
	info
	exit 1
	;;
esac

cur_dir=$PWD
if [ ! -d "$proj" ]; then 
    mkdir $proj 
else
    echo "Error. Analysis dir $proj exists." > /dev/stderr
    exit 1
fi

cd $proj

if [ "`echo $HOME | grep -c afs`" = "0" ]; then 
    home=/home/tesi/data/
else
    home=$HOME
fi
cp -R $home/analysis_skel/* ./

if [ "$subLevel" != "0" ]; then
    for i in `seq $subLevel -1 1`; do
	cd ..; level[$i]=`basename $PWD`
    done
fi

for i in ${level[@]}; do
    cd $i
done



for i in ${#level[@]}; do
    echo "$i ${level[$i]}" >> .cur_level
done

cd $cur_dir

exit 0



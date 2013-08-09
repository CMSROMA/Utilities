#!/bin/bash

castorDir=$CASTOR_HOME/calibration/7TeV/Higgs/sandbox
sample=$1
eosDir=/store/caf/user/shervin/calibration/7TeV/Higgs/sandbox

cmsMkdir $eosDir/$sample

echo "[STATUS] Making filelist"
makefilelist.sh $sample $castorDir/$sample

for file in `cat filelist/$sample.list`;
  do
#  echo $file
  xrdcp root://castorcms//$file root://eoscms//eos/cms/$eosDir/$sample/`basename $file`
done

#$castorDir/$sample/*.root 

exit 0

PREFIX=Higgs

usage(){
    echo "Usage: `basename $0` ./filelist/sample.list" > /dev/stderr
}

case $# in
    0)
	echo -n "Error: "
	usage
	exit 1
	;;
    *)
	;;
esac

for i in $@; do
    echo -n "Check file $i: "
    if [ ! -r "$i" ]; then 
	echo "File $i not found or not readable" 
	exit 1
    fi
    echo
done

for ciao in $@; do
    filelist=(`cat $ciao`)
    sample=`basename $ciao .list`
    
# creo la cartella
    if [ ! -d "/u2/" ]; then 
	dir=/tmp/$USER/$PREFIX/skimmed/$sample
    else
	dir=/u2/$USER/$PREFIX/skimmed/$sample
    fi

    if [ ! -d "$dir" ]; then
	mkdir $dir -p
    fi
    
    echo "Copy $ciao"
    for i in ${filelist[@]}; do
	echo "- copy: $i"
	file=`basename $i`
	if [ ! -r "$dir/$file" ]; then 
#	    (rfcp $i $dir &)
	    rfcp $i $dir &
	fi
    done
done

wait

echo "Copy completed"
exit 0
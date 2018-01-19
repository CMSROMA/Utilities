#!/bin/bash

# this is to kill with control+C also the subshells
#trap '[[ -z "$(jobs -p)" ]] || kill $(jobs -p)' EXIT 

ID=`uuidgen -r | cut -d '-' -f 2`
outFile=$1
mkdir -p `dirname $outFile`
tmpDir=/tmp/$USER/tmpHadd/`dirname $1`/`basename $2 .list`-$ID # this is the base path
tmpList=$tmpDir/filelist.list

echo "tmpDir=$tmpDir"
echo "tmpList=$tmpList"
mkdir -p $tmpDir
cp $2  $tmpList


cd $tmpDir


nFiles=5





iterNumber=0

while [ "`wc -l $tmpList |cut -d ' ' -f 1`" != "1" ];
do
	let iterNumber=$iterNumber+1
	let nFiles=$nFiles*$iterNumber # merge a larger number of files at each iteration
	echo "############################## ITER: $iterNumber : $nFiles : `wc -l $tmpList`"
	iterDir=${tmpDir}/$iterNumber
	mkdir -p ${iterDir}/tmp
	cd ${iterDir}
    # make sub-lists with the files, splitting the original list by $nFiles
	prefix=split_${iterNumber}_
	cd tmp/
	split -a 3 -l $nFiles -d $tmpList ${prefix}
	cd ../

	# make the hadd for each sub-list in parallel
	for splitList in tmp/${prefix}[0-9][0-9][0-9]
	do
#		echo "------------------------------ $splitList"
		iterFile=${iterDir}/`basename $splitList`.root
		(nice -18 hadd $iterFile `cat $splitList` &> /dev/null || touch failed) &
		joblist=($(jobs -p))
		while (( ${#joblist[*]} >= 20 )); do sleep 1; joblist=($(jobs -p)); done
#	   echo  $iterFile 
#	   cat $splitList
#		echo $!
#		pids="$pids $!"
	done
	wait # wait that all the hadds are finished
	if [ -e "failed" ];then 
		rm ${tmpDir}/* -Rf
		exit 1
	fi
	cd $tmpDir
#	echo $pids
	
	# update the list of files to be merged with the temporary sub-merged files
	ls ${iterDir}/*.root > $tmpList
#	cat $tmpList


done

cp `cat $tmpList` $outFile

rm ${tmpDir}/* -Rf


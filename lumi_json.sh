#!/bin/bash

usage(){
    echo "Usage: `basename $0` json_file.json lumi_file.csv" > /dev/stderr 
}

get_extention(){
    ext=`echo $1 | sed 's|.*\.||'`
    echo $ext
}

case $# in 
    2)
	json=$1
	lumi=$2
	;;
    *)
	echo -n "Error. " > /dev/stderr
	usage
	exit 1
esac

if [ "`get_extention $json`" != "json" ];then
    echo "Error: not json file as first argument" > /dev/stderr
    usage
    exit 1
fi

if [ "`get_extention $lumi`" != "csv" ];then
    echo "Error: not csv file as second argument" > /dev/stderr
    usage
    exit 1
fi


cd ~/CMSSW_3_8_0/; eval `scramv1 runtime -sh`; cd -
lumiCalc.py -c frontier://LumiProd/CMS_LUMI_PROD -i $json lumibyls -o $lumi --nowarning
sed -i '1 d' $lumi

exit 0



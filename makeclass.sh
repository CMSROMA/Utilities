#!/bin/bash

usage(){
    echo "Usage: `basename $0` tree_name file nameclass [data]" > /dev/stderr
}

flag=""

case $# in 
    3)
	;;
    4)
	flag=$4
	;;

    *)
	echo -n "Error. "
	usage
	exit 1
	;;
esac

tree_name=$1
file=$2
nameclass=$3

echo "/* inserire il valore dei file in n_file */" > ./makeclass.cc
echo "{" >> ./makeclass.cc
echo "  gROOT->Reset();" >> ./makeclass.cc
echo "  TChain chain(\"$tree_name\");" >> ./makeclass.cc
#for i in `ls -1 $dir/*.root`; do
echo "  chain.Add(\"$file\");" >> ./makeclass.cc
#done
echo >> ./makeclass.cc
echo "  chain->MakeClass(\"$nameclass""\");" >> ./makeclass.cc
echo "}" >> ./makeclass.cc
echo  >> ./makeclass.cc

echo "Creo le classi dal file root" > /dev/stderr
root -l -b -q makeclass.cc || exit 1 # crea le classi

rm makeclass.cc

if [ -e "sed/class.sed" ];then
    sed -i -f sed/class.sed $nameclass.h 
fi

sed -i "/Loop()/ d" $nameclass.h
rm $nameclass.C
#sed -i "s|$nameclass|../include/$nameclass|" $nameclass.C 

if [ "$flag" != "" ]; then
    mv $nameclass.h $nameclass-$flag.h
else
    mv $nameclass.h $nameclass-MC.h
fi

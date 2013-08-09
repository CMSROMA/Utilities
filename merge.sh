#!/bin/bash

batch_dir=.
batch_root_dir=batch_root


# prendo la lista delle cartelle
dirlist=(`ls $batch_dir/$batch_root_dir/`)


# questo e' il separatore dell'espasione di parametro con *

# per ogni cartella 
#IFS=|
for i_dir in ${dirlist[@]}; do
    # prendo la lista dei file per ogni cartella
#    filelist=(`ls $batch_dir/$batch_root_dir/$i_dir`)
 
   # prendo il nome della chain relativa alla cartella
    chain_name=`echo $i_dir | sed 's|_chain-[0-9]*||'`
    chain_num=0

    case $chain_name in 
	b1 | s ) 
	    
    	;;
	*)
	    
	;;
    esac
done

chain_list=(`echo "b1 s"`)
echo "{"

# dichiaro i merger
for i_chain in ${chain_list[@]}; do
    echo "  TFileMerger $i_chain;"
done



for i_dir in ${dirlist[@]}; do
    chain_name=`echo $i_dir | sed 's|_chain-[0-9]*||'`
    i_file=`ls $batch_dir/$batch_root_dir/$i_dir`
    echo -n "  $chain_name.AddFile(\""
    echo -n $batch_dir/$batch_root_dir/$i_dir/$i_file
    echo "\");"
done

echo
for i_chain in ${chain_list[@]}; do
   
    echo "  $i_chain.OutputFile(\"$i_chain.root\");"
    echo "  $i_chain.Merge();"
done
echo "}"

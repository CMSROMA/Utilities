#!/bin/bash
# this script takes in input one file with the list of root files 
# creates a subdir with the sample name
# split the list in sub-lists of n_chain number of files

usage(){
    echo "Usage: `basename $0` [-a] sample [n_chain=10]"     > /dev/stderr
    echo "       n_chain = numero di file in una chain" > /dev/stderr
}

# if there is the filelist subdir create the splitted file-dir in it
if [ -d "./filelist/" ]; then
    filelist_dir=./filelist
else
    filelist_dir="./"
fi
unset add

while getopts haf: option
  do
  case $option in
      h)
	  usage
	  exit 0
	  ;;
      a)
	  echo "[OPTION] making filelist adding directory, if it is the same dir a new file will be created"
	  add=yes
	  ;;
      f)
	  echo "[OPTION] File to split: $OPTARG"
	  filelistToSplit=$OPTARG
	  ;;
      *)
	  echo -n "ERROR --> "
	  usage
	  exit 1
          ;;
  esac
done

#while getopts "h" OPTIONS ; do
#    case ${OPTIONS} in
#        h|-help) echo "${usage}";;
#    esac
#done

shift $(($OPTIND-1))


case $# in 
    1)
	sample=`basename $1 .list`
	n_chain=10
	;;
    2)
	sample=`basename $1 .list`
	n_chain=$2
	;;
    *)
	usage
	exit 1
	;;
esac

case $n_chain in
    all)
	# faccio un unica chain
	n_chain=`wc -l $filelist_dir/$sample.list | cut -d ' ' -f 1`
	;;
    *)
	;;
esac

if [ -z "$filelistToSplit" ];then
    filelistToSplit=$filelist_dir/$sample.list
fi

if [ ! -r "$filelistToSplit" ]; then
    echo "error: $filelist_dir/$sample.list not found or not readable" > /dev/stderr
    exit 1
fi

if [ ! -d "$filelist_dir/$sample" ]; then
    mkdir $filelist_dir/$sample -p
else
    if [ -n "$add" ]; then 
	cat $filelist_dir/$sample/*.list > oldChains.list
    else
	rm $filelist_dir/$sample/*.list; 
	if [ -e "oldChains.list" ];then rm oldChains.list; fi
    fi
fi

#num_chain=`cat $filelist_dir/$sample.list | wc -l`

#n=0;
#i_chain=0

# rimuovo i file in blacklist e dalle vecchie chain
cp $filelist_dir/$sample.list tmpfile
for f in `cat $filelist_dir/$sample.blacklist oldChains.list`;
  do
  grep -v $f tmpfile > tmpf
  mv tmpf tmpfile
done


# creo la chain da tmpfile senza blacklist
mkdir -p $filelist_dir/$sample/tmp
mv tmpfile $filelist_dir/$sample/tmp
cd $filelist_dir/$sample
if [ -n "$add" ];then 
    last_Oldchain=`ls -1 *.list | tail -2 | sed 's|$sample-||;s|.list||'`
else
    last_Oldchain=0
fi
cd tmp
split -a 3 -l $n_chain -d tmpfile $sample-
rm tmpfile

i_chain=$last_Oldchain
for file in *;
  do 
#  i_chain=`echo "$i_chain+1" | bc`
#  i_chain=`seq -f %03.0f $i_chain $i_chain`
  i_chain=`echo "$i_chain" | awk '{printf("%03d\n", $0+1)}'`
  newFile=`echo $file | sed 's|-[0-9][0-9][0-9]$||'`-$i_chain
  mv $file ../$newFile.list
done

cd ../../../
rm $filelist_dir/$sample/tmp/ -Rf

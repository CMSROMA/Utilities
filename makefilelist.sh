#!/bin/bash
# author: Shervin
# date: 11/04/2010
# version 2.0

# questo script crea un file con una lista di root file contenuti in una directory
# escludento certi pattern di file indicati dal file exclude in filelist/


# con l'opzione batch crea un chain separata per ogni file
# sta

# se la directory e' su castor usa rfdir per individuare i file
# altrimenti usa ls -l

filelist_dir=./filelist
#exclude="nEle"
#exclude="-f $filelist_dir/exclude"
#if [ ! -r "$filelist_dir/exclude" ]; then
#    echo "Warning: file $filelist_dir/exclude not found or not readable" >> /dev/stderr
#    if [ ! -r "$HOME/bin/find" ]; then 
#	echo "         using $HOME/bin/find instead" >> /dev/stderr
#    else
#	exclude="nEle"
#    fi
#fi



# in batch mode il puntatore alla chain si chiama: batch_chain

usage(){
    echo "`basename $0` [option] sample directory " 
    echo "--------- optional"
    echo "    -g, --grep arg: merge files matching the argument"
    # tree_name e' il nome del tree dentro i root-file
    # chain_name e' il nome che voglio dare alla chain
    # directory e' il path in cui si trovano i root-file
    # con l'opzione batch la lista dei file viene spacchettata in piu' 
    #  chain, e il nome della chain e' batch_chain
}


get_par(){
    echo $1 | cut -d '=' -f 2
}


recursive=no

#------------------------------ parsing
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -u -o hacrpg:lf: -l help,grep: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
  do
  case $1 in
      -h|--help) usage; exit 0;;
      -a) 
	  echo "[OPTION] making filelist adding directory, if it is the same dir a new file will be created"
	  add=yes
	  ;;
      -c) export CONTINUE="yes";;
      -r) echo "recursive"; recursive=yes;;
      -g|--grep ) echo "[GREP OPTION]: $2"; GREP=$2;  shift;;
      -p)  # configure python filelist for cmsRun
	  PYTHON_CFG=yes
	  ;;
      -l) LIST_OPT="true";;
      -f) echo "[OPTION] Filelist directory: $2"; filelist_dir=$2; shift;;
      (--) shift; break;;
      (-*) echo "$0: error - unrecognized option $1" 1>&2; usage >> /dev/stderr; exit 1;;
	(*) break;;
  esac
  shift
done

case $# in 
    2)
	;;
    3)
	case $3 in
	    local)
		local=_local
		;;
	    *)
		echo "Error. $input parameters" >> /dev/stderr
		usage
		exit 1
		;;
	esac
	;;
    *)
	echo  "[ERROR] Wrong number of parameters: $#"
	echo  "Usage:"
	usage
	exit 1
	;;
esac

sample=$1
dir=$2

# se non esiste la cartella di destinazione la creo
if [ ! -e $filelist_dir ];then
    mkdir -p $filelist_dir 
fi

new_file=$filelist_dir/$sample.list$local
#rinomino il vecchio file per sicurezza 

if [ -n "$CONTINUE" -a -e "$new_filel" ]; then 
    echo "File exists: CONTINUE" > /dev/stdout
    exit 0
fi

if [ -z "$add" -a -e  "$new_file" ]; then
    echo "[ERROR] file $new_file exist" >> /dev/stderr
    echo "        Try to remove it!"    >> /dev/stderr
    exit 1;
#    mv $filelist_dir/$sample.list $filelist_dir/$sample.list-old
fi

# se prendo i root file da castor cerco il comando rfdir
   # if [ "`echo $dir | grep -c castor`" != "0" ]; then
case $dir in 
    *castor*)
	   if [ "`whereis rfdir | cut -d ':' -f 2 | wc -w`" = "0" ];then
	       echo -n "Error. " >> /dev/stderr
	       echo "Command rfdir not found" >> /dev/stderr
	       exit  1
	   fi
	   dir_command='rfdir'
	   ;;
    root://*eos*)
	   echo "[INFO] Files on xrootd server"
	   dir_command='/afs/cern.ch/project/eos/installation/pro/bin/eos.select ls -l'
	   file_prefix="root://eoscms.cern.ch/"
	   dir=`echo $dir | sed 's|root://eoscms.*//eos|/eos|'`
	   ;;

    /store/*)
	   dir_command='/afs/cern.ch/project/eos/installation/pro/bin/eos.select ls -l'
	   file_prefix="root://eoscms.cern.ch/"
	   dir_prefix="/eos/cms"
	   ;;

    *eos*)
	   dir_command='/afs/cern.ch/project/eos/installation/pro/bin/eos.select ls -l'
	   file_prefix="root://eoscms.cern.ch/"
	   ;;

    *)
	   dir_command='ls -l'
	   ;;
esac
    #fi
dir=$dir_prefix$dir
filelist_=(`$dir_command $dir | sed '/^d/ d' | grep '.root' | awk '(NF!=0){print $9}'`)
dirlist=(`$dir_command $dir | sed '/^-/ d' | awk '(NF!=0){print $9}'`)

if [ -n "$LIST_OPT" ];then
    echo "${dirlist[@]}"
    exit 0
fi

if [ "${#filelist_[@]}" = "0" ]; then
    echo "No files in the directory" >> /dev/stderr
    echo "List of subdirectories:" >> /dev/stderr
    for i in ${dirlist[@]}; do
	echo " - $i" >> /dev/stderr
    done
    if [ "$recursive" = "no" ]; then
	exit 1;
    fi
    for i in ${dirlist[@]}; do
	makefilelist.sh -a -r $sample-$i $dir/$i 
    done
    exit 0
fi

    # elimino le directory, prendo i rootfile, ne prendo il nome, ci metto aggiungo il path
if [ -z "${GREP}" ]; then
    $dir_command $dir | sed "/^d/ d" | grep '.root' | awk '(NF!=0){print $9,$5}' | sed "s|^|$file_prefix$dir/|" >> $new_file.1
else
    $dir_command $dir | sed "/^d/ d" | grep -e "${GREP}.*root" | awk '(NF!=0){print $9,$5}' | sed "s|^|$file_prefix$dir/|" >> $new_file.1
fi
#else 
#    echo "file list reading"
#    filelist_=(`cat $dir | sed 's|rfio:/||'`);
#    dir=""
#fi


#if [ ! -e $filelist_dir/$sample.blacklist ]; then
#    touch $filelist_dir/$sample.blacklist
#fi


#cat $new_file.1  |   sed '/^$/ d'  |sort > $new_file.2
for dir in $HOME/bin $PWD/bin `echo $PATH | sed 's|:| |g'`
  do
  if [ -e $dir/remove_dup.awk ];then
      REMDUP=$dir/remove_dup.awk
      break
  fi
done

if [ -z "$REMDUP" ];then 
    echo "[ERROR] remove_dup.awk not found in $HOME/bin $PWD/bin $PATH" >> /dev/stderr
    echo "[     ] `echo $PATH | sed 's|:| |g'`"
    exit 1
fi
awk -f $REMDUP $new_file.1 | \
   sed '/^$/ d;s|\t.*$||;s| .*||'  |sort > $new_file.2
cp $new_file.1 $new_file.dump

# rimuovo i duplicati di castor, tolgo le righe vuote, tolgo i file da escludere
if [ -n "$add"  ];then
	if [ ! -e "${new_file}" ];then
		cp ${new_file}.2 ${new_file}
	else
#    echo "Adding old filelist to the new one to remove duplicates"
#	echo ${new_file}.2 $new_file
    diff $new_file.2 $new_file  > $new_file.diff
    if [ "`cat $new_file.diff | wc -l `" == "0" ];then
	rm $new_file.diff $new_file.1 $new_file.2
	exit 0
    fi
	fi 
    if [ "`grep -c '<' $new_file.diff`" != "0" ]; then
	echo "[WARNING] Missing file for sample $sample!"
	echo "          Look at $new_file.missingDiff"
	grep '<' $new_file.diff > $new_file.missingDiff
    fi
    grep '<' $new_file.diff > $new_file.diff2
    sed  '/</ d; s|> ||' $new_file.diff2 > $new_file.diff
    rm $new_file.diff2
    cat $new_file.diff >> $new_file
    rm $new_file.2
    exit 1
else
    mv $new_file.2 $new_file
fi


rm $new_file.1


sortCrabFilelist.sh $new_file #|| exit 2

if [ -n "$PYTHON_CFG" ]; then
    echo 'myfilelist.extend( [' > $filelist_dir/$sample'_cff.py'
    sed "s|^|  \'rfio:\/\/|; s|$|\',|" $new_file >> $filelist_dir/$sample'_cff.py'
    echo "] )" >> $filelist_dir/$sample'_cff.py'
fi


exit 0





#!/bin/bash
usage(){
    echo "Usage: `basename $0` sample" > /dev/stderr
}



while getopts ha option
  do
  case $option in
      h)
	  usage
	  exit 0
	  ;;
      a)
	  echo "[OPTION] updating batch directory"
	  ADD_OPT=true
	  ;;
      c)
          export CONTINUE="yes"  
          ;;
      r)
	  echo "recursive"
	  recursive=yes
	  ;;
      g)
#	--grep=*)
	  GREP=$OPTARG
	  ;;
      p)
	  # configure python filelist for cmsRun
	  PYTHON_CFG=yes
	  ;;
      l)
	  LIST_OPT="true"
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
	sample=$1
	;;
    *)
	#	samplelist=(`ls filelist/*.list`)
        # copio lo script da eseguire in batch dalla cartella script a quella batch
	echo "Select one sample" > /dev/stderr
	usage
	exit 1
	;;
esac


export analysis=`basename $PWD`
if [ -z "$CMSSW_VERSION" ]; then
    echo "CMS environment not loaded yet" > /dev/stderr
    echo " please do cmsenv before"       > /dev/stderr
    exit 1
fi

if [ ! -d "./script/" ]; then
    echo "script dir not found"
    exit 1
fi

# controllo che ci sia la cartella batch:
if [ ! -d "./batch" ]; then
    echo "Cartella batch non trovata" > /dev/stderr
    makebatchdir.sh || exit 1;

fi

echo "Creating lxbatch job for analysis: $analysis"

tar --exclude *~ -hcf batch/$analysis.tar build/ filelist/ script/ config/


#sample=`basename $j .list`
    
    # preparo le cartelle per i logfile
if [ -d "./batch/log/$sample" ]; then
    if [ -n "$ADD_OPT" ];then
	tar -czvf batch/$sample.tgz batch/log/$sample
	rm batch/log/$sample/* -Rf
    else
	echo "Eliminare la cartella ./batch/log/$sample prima di preparare un nuovo batch" > /dev/stderr
	exit 1
    fi
else
    mkdir ./batch/log/$sample -p
fi

    #creo gli joblist
if [ -e "./batch/$sample""_joblist" ]; then
    rm ./batch/$sample""_joblist
fi
if ! ls filelist/$sample/*.list &> /dev/null ;then
    echo "warning: no chain list in ./filelist/$sample/"   > /dev/stderr
    echo "         going to make 1 chain with all $j file" > /dev/stderr
    makechain.sh $sample all
fi
for i in `ls filelist/$sample/*.list`; do 
    echo $i >> ./batch/$sample"_joblist"
done 




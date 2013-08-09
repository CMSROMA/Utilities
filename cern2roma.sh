#!/bin/bash
command="lcg-cp --verbose --vo cms -n 4 --checksum"
EndPointSE=srm://cmsrm-se01.roma1.infn.it/pnfs/roma1.infn.it/data/cms
#StartPointSE=srm://srm-cms.cern.ch/castor/cern.ch
#StartPointDirBase=user/e/emanuele/Crab2/Vecbos2011/Data2011_V8

#StartPointDirBase=/store/cmst3/user/crovelli/CMST3/jetsCalib/
#StartPointDir=user/e/emanuele/Crab2/Vecbos2011/Data2011_V8/PromptRecoV4/SingleMu

#EndPointDirBase=user/lsoffi/data/Vecbos2011/SingleMu_Run2011A
#EndPointDirBase=/store/user/lsoffi/ProdSummer12/jetsCalib/

setStartPoint(){
  case $1 in
      root://eoscms.cern.ch/*)
	  StartPointSE=srm://srm-eoscms.cern.ch/eos/cms
	  file=`echo $file | sed "s|root://eoscms.cern.ch//eos/cms|${StartPointSE}|"`
	  ;;
      root://eoscms/*)
	  StartPointSE=srm://srm-eoscms.cern.ch/eos/cms
	  file=`echo $file | sed "s|root://eoscms//eos/cms|${StartPointSE}|"`
	  ;;
      */eos/cms/*)
	  StartPointSE=srm://srm-eoscms.cern.ch/eos/cms
	  file=`echo $file | sed "s|.*/eos/cms|${StartPointSE}|"`
	  ;;

      *)
	  echo "[ERROR] Non so, esci"
	  exit 1
	  ;;
  esac
}

usage(){
    echo "`basename $0` options"
    echo "    --inputDir arg: directory on EOS"
    echo "                   (e.g. /eos/cms/store/group/alca_ecalcalib/ecalelf/alcaraw/8TeV/)"
    echo "                   (e.g. root://eoscms//eos/cms/store/group/alca_ecalcalib/ecalelf/alcaraw/8TeV/)"
    echo "    --inputFileList arg: file containing the list of files to be copied"
    echo "    --outputDir arg: output directory (start from /store)"
    echo "                   (e.g. /store/user/lsoffi/ProdSummer12/jetsCalib"
    echo "    --check: check the output files"
    echo "----------"
    echo "    --help"
}


#------------------------------ parsing
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -u -o h -l help,inputDir:,intputFileList:,outputDir:,check -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
	-h|--help) usage; exit 0;;
	--inputDir) INPUTDIR=$2; shift ;;
	--inputFileList) INPUTFILELIST=$2; shift ;;
	--outputDir) OUTPUTDIR=$2 ; shift;;
	--check)      echo "[OPTION] checking output files"; CHECKEND=y;;
	(--) shift; break;;
	(-*) echo "$0: error - unrecognized option $1" 1>&2; usage >> /dev/stderr; exit 1;;
	(*) break;;
    esac
    shift
done



if [ -z "${OUTPUTDIR}" ];then
    echo "[ERROR] Output directory not specified: use the --outputDir option" >> /dev/stderr
    exit 1
fi

if [ -z "${INPUTDIR}" -a -z "${INPUTFILELIST}" ];then
    echo "[ERROR] Neither input directory containg the files nor file list provided" >> /dev/stderr
    exit 1
fi

if [ -n "${INPUTDIR}" ];then
    makefilelist.sh copy2rome ${INPUTDIR}
    INPUTFILELIST=filelist/copy2rome.list
fi


EndPointDirBase=${OUTPUTDIR}

dir=copylog/`basename ${INPUTFILELIST} .list`
mkdir -p $dir

exec <${INPUTFILELIST}
while read i
  do
  file=$i
  #input file reset with srm path
  setStartPoint $file

  StartPointDirBase=`dirname $file | sed "s|{$StartPointSE}||"`
  endFile=$EndPointSE/$EndPointDirBase/`basename $file`

  #srmmkdir `dirname $endFile` || exit 1

  if [ -n "$CHECKEND" ];then
      lcg-ls ${endFile} &> /dev/null || {
	  echo "$file" >> $dir/notCopied.list
      }
  else
      ( $command $file \
	  ${endFile} &> $dir/`basename $file .root`.log && {
	      rm $dir/`basename $file .root`.log
	      echo "$file ${endFile}" >> $dir/copied.log
	      echo "$file [DONE]"
	  } 
      ) &

      if [ "`ps -u shervin | grep -c lcg-cp`" -gt 20 ];then 
	  /bin/sleep 20s
      fi
  fi

done

wait


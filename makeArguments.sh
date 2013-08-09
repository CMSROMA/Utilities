#!/bin/bash
usage(){
    echo "`basename $0` -f filelist -u ui_working_dir [-n file_per_job | --nJobs] "
    echo "    -f, --filelist: can specify many time, one for each filelist "
}


#------------------------------ parsing
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -u -o hf:n:u: -l help,filelist:,file_per_job:,nJobs:,ui_working_dir:,parentFilelist: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
	-h|--help) usage; exit 0;;
	-f|--filelist) FILELIST="$FILELIST $2"; shift ;;
	-p|--parentFilelist) PARENTFILELIST="$PARENTFILELIST $2"; shift;;
	-n|--file_per_job) FILE_PER_JOB=$2; shift ;;
	--nJobs) NJOBS=$2; shift;;
	-u|--ui_working_dir) UI_WORKING_DIR=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage >> /dev/stderr; exit 1;;
    (*) break;;
    esac
    shift
done



#------------------------------ checking
if [ -z "$FILELIST" ];then 
    echo "[ERROR] FILELIST not defined" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
fi

if [ -z "$UI_WORKING_DIR" ];then 
    echo "[ERROR] UI_WORKING_DIR not defined" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
fi

tmpFilelist=filelist/filelist.list
cat $FILELIST > $tmpFilelist


if [ -n "$NJOBS" ];then
    nFiles=`cat $FILELIST | wc -l`
    let FILE_PER_JOB=$nFiles/$NJOBS
    if [ "`echo \"$nFiles%$NJOBS\" | bc`" != "0" ];then
	let FILE_PER_JOB=$FILE_PER_JOB+1
    fi
fi



# if FILE_PER_JOB is not specified uses makechain.sh default: 10
makechain.sh $tmpFilelist $FILE_PER_JOB



#============================== Writing the argumets file
cat > $UI_WORKING_DIR/share/arguments.xml <<EOF
<arguments>
EOF

for file in filelist/`basename $tmpFilelist .list`/*.list
  do

  job=`basename $file .list | sed 's|.*-\([0-9]*\)|\1|'`
#  echo $job
  files="`cat $file | sed 's|$|,|'`"
  cat >> $UI_WORKING_DIR/share/arguments.xml <<EOF
  <Job MaxEvents="-1"  JobID="$job" InputFiles="$files">
  </Job>
EOF
sed -i 's|,">|">|' $UI_WORKING_DIR/share/arguments.xml

done

cat >> $UI_WORKING_DIR/share/arguments.xml <<EOF
</arguments>
EOF






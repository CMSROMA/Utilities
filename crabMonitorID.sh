#!/bin/bash
usage(){
    echo "`basename $0` -u crab_working_dir -n DATASETNAME -r RUNRANGE --type TYPE [-t TAG]"
    echo " -r XXX-YYY"
    echo " --type SANDBOX|ALCARECO|RERECO|NTUPLE"
    echo " -t TAG (if type=RERECO)"
}

#------------------------------ parsing
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -u -o hu:n:r:t: -l help,datasetpath:,datasetname:,runrange:,type:,tag: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
        -h|--help) usage; exit 0;;
	-u) UI_WORKING_DIR=$2; shift;;
        -d|--datasetpath) DATASETPATH=$2; shift ;;
        -n|--datasetname) DATASETNAME=$2; shift ;;
        --type) TYPE=$2 ; shift;;
        -r|--runrange) RUNRANGE=$2; shift;;
	-t|--tag) TAG=$2; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage >> /dev/stderr; exit 1;;
    (*) break;;
    esac
    shift
done

case $TYPE in
    RERECO)
	TYPE=${TYPE}_`basename ${TAG} .py`
	;;
    *)
	;;
esac

sed -i "s|^MonitorID=.*_\(.*\)|MonitorID=${DATASETNAME}_${RUNRANGE}_${TYPE}_\1|" ${UI_WORKING_DIR}/job/CMSSW.sh
sed -i "s|^CRAB_UNIQUE_JOB_ID=.*\${OutUniqueID}|CRAB_UNIQUE_JOB_ID=${DATASETNAME}_${RUNRANGE}_${TYPE}_\${OutUniqueID}|" ${UI_WORKING_DIR}/job/CMSSW.sh

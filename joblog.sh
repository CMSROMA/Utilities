#!/bin/bash
EXITSTATUS=0
thereislogfile(){
    ls *-out.log &> /dev/null || {
	echo "No logfile remained"
	exit $EXITSTATUS
    }
}

thereislogfile


# list of term owner jobs
if [ ! -e "termownerjob.log" ]; then
    list1=`grep -H 'Exited with exit code 130' *-out.log | cut -d ':' -f 1 | sed 's|-out.log||'`
    list2=`grep -H 'Exited with signal termination: Killed' *-out.log | cut -d ':' -f 1 | sed 's|-out.log||'`
    list=`echo $list1 $list2`
    if [ -n "$list" ]; then 
	if [ ! -d "termowner" ]; then mkdir termowner; fi
	errors="$errors TERM_OWNER"
    fi
    for i in $list; do 
	dir=`echo $i |sed 's|-[0-9]*$||'`; 
	echo filelist/$dir/$i.list >> termownerjob.log
	mv $i-out.log termowner/
	mv $i-err.log termowner/
	EXITSTATUS=1
    done
fi

thereislogfile

# list of aborted jobs

if [ ! -e "abortedjob.log" ]; then
    list=`grep -H 'std::bad_alloc' *-err.log | grep terminate | cut -d ':' -f 1 | sed 's|-err.log||'`
    if [ -n "$list" ];then 
	if [ ! -d "aborted" ]; then mkdir aborted; fi
	errors="$errors ABORTED"
    fi
    for i in $list; do 
	dir=`echo $i |sed 's|-[0-9]*$||'`; 
	echo filelist/$dir/$i.list >> abortedjob.log
	mv $i-out.log aborted/
	mv $i-err.log aborted/
	EXITSTATUS=1
    done
fi

thereislogfile


# list of time limit exceded job
#echo " Control time exceeded jobs"
if [ ! -e "timeexceededjob.log" ]; then
    list=`grep -H 'CPU time limit' *-out.log | cut -d ':' -f 1 | sed 's|-out.log||'`
    if [ -n "$list" ];then 
	if [ ! -d "timeexceeded" ]; then mkdir timeexceeded; fi
	errors="$errors TIME EXCEEDED"
    fi
    for i in $list; do 
	dir=`echo $i |sed 's|-[0-9]*$||'`; 
	echo filelist/$dir/$i.list >> timeexceededjob.log
	mv $i-out.log timeexceeded/
	mv $i-err.log timeexceeded/
	EXITSTATUS=1
    done
fi

# if [ ! -e "timeexceeded.log" ]; then
#     grep -H 'CPU time limit' *-out.log | cut -d ':' -f 1 | sed 's|-out.log||' > timeexceeded.log
#     if [ -s timeexceeded.log ];then
# #	echo "  --> Time exceeded job number: `wc -l timeexceeded.log`"
# #	echo "      moving timeexceeded job logfile in timeexceeded/"
# 	mkdir timeexceeded/
# 	mv `cat timeexceeded.log | sed 's|$|-err.log|'` timeexceeded/
# 	mv `cat timeexceeded.log | sed 's|$|-out.log|'` timeexceeded/
#     else
# 	rm timeexceeded.log
#     fi
# fi

thereislogfile

# failedlist e' la lista dei root file che hanno prodotto il failing
# failedjob.log e' il job in cui si trova il file
#echo " Control failing jobs"
if [ ! -e "failedjob.log" ];then
    if [ "`grep -H failing *-err.log | wc -l`" != "0" ];then
#	echo "  --> Failing job found: creating failedjob.log"
#	echo "      try to restart jobs with:"
#	echo " ./start.sh \`cat failedjob.log\`  "
	grep -H failing *-err.log |  sed 's|-err.log.*///| /|' |   awk '(NF!=0){if ($1 != failedjob[$1]){failedjob[$1]=$1;} print $2}END{for (i in failedjob){file=i; gsub("-[0-9]*$","",i);printf("filelist/%s/%s.list\n" ,i,file) > "failedjob.log"}}' > failedlist || exit 1
	
	if [ ! -d failed ]; then mkdir failed/ ;fi
	mv `cat failedjob.log | sed 's|.list$|-err.log|;s|filelist.*/||'` failed/
	mv `cat failedjob.log | sed 's|.list$|-out.log|;s|filelist.*/||'` failed/
	EXITSTATUS=1
    fi
fi
thereislogfile

# list of other exited job
#grep -H 'Exited' *-out.log | grep -v 'CPU time limit' > otherExited.log

#echo " Controlling truncated jobs"
if [ ! -e "truncatedjob.log" ]; then
    if [ "`grep -H truncated *-err.log | sed '/SetBranch/ d' | wc -l`" != "0" ]; then
#	echo "  --> Truncated job found: creating truncatedjob.log"
	grep -H truncated *-err.log | \
	    sed 's|-err.log.*||' | \
	    awk '(NF!=0){if($1 != job[$1]){job[$1]=$1} print $2}END{for (i in job){print i > "truncatedjob.log"}}' > truncatedlist
	sed -i 's|:.*||;s|^|./filelist/|;s|$|.list|' truncatedjob.log
	if [ ! -e "truncated" ]; then mkdir truncated/; fi
	mv `cat truncatedjob.log | sed 's|$|-err.log|'` truncated/
	mv `cat truncatedjob.log | sed 's|$|-out.log|'` truncated/
# #    rmdir `cat truncatedjob.log | sed 's|^|./batch_root/|'`
	EXITSTATUS=1
    fi
fi

thereislogfile
#echo " Controlling segmentation violation"
# if [ ! -e "violated.log" ]; then
#     if [ "`grep -H violation *-err.log | wc -l`" != "0" ]; then
# #	echo "  --> Segmentation violated job found: creating violated.log"
# 	grep -H violation *-err.log | cut -d ':' -f 1 | sed 's|-err.log||' > violated.log
# 	if [ ! -e violated ];then mkdir violated; fi
# 	mv `cat violated.log | sed 's|$|-out.log|'` violated/
# 	mv `cat violated.log | sed 's|$|-err.log|'` violated/
#     fi
# fi

if [ ! -e "violatedjob.log" ]; then
    list=`grep -H 'violation' *-err.log | cut -d ':' -f 1 | sed 's|-err.log||'`
    if [ -n "$list" ];then
        if [ ! -d "violated" ]; then mkdir violated; fi
        errors="$errors VIOLATED"
	EXITSTATUS=1
    fi
    for i in $list; do
        dir=`echo $i |sed 's|-[0-9]*$||'`;
        echo filelist/$dir/$i.list >> violatedjob.log
        mv $i-out.log violated/
        mv $i-err.log violated/
    done
fi

thereislogfile

# rm `cat done.log | sed 's|$|-err.log|'`
# rm `cat done.log | sed 's|$|-out.log|'`
# #rm `sed 's|-out.log|-err.log|' done.log`



#echo " Controlling term_runlimit jobs"
if [ ! -e "term_runlimit.log" ];then
    if [ "`grep -H TERM_RUNLIMIT *-out.log | wc -l`" != "0" ]; then
#	echo "  --> TERM_RUNLIMIT job found: creating term_runlimitjob.log"
	grep -H TERM_RUNLIMIT *-out.log | \
	    cut -d ':' -f 1 | sed 's|-out.log||' > term_runlimitjob.log
	
	if [ ! -e "term_runlimit" ]; then mkdir term_runlimit/; fi
	mv `cat term_runlimitjob.log | sed 's|$|-err.log|'` term_runlimit/
	mv `cat term_runlimitjob.log | sed 's|$|-out.log|'` term_runlimit/
# #    rmdir `cat truncatedjob.log | sed 's|^|./batch_root/|'`
	EXITSTATUS=1
    fi
fi


thereislogfile

# fatto per rfcp: Time out
if [ ! -e "timeoutjob.log" ]; then
    if [ "`grep -H 'Timed out' *-err.log | wc -l`" != "0" ]; then
#	echo " --> rfcp: Time out job foundL creating timeoutjob.log"
	grep -H 'Timed out' *-err.log | \
	    cut -d ':' -f 1 | sed 's|-err.log||' > timeoutjob.log
	
	if [ ! -e "timeout" ]; then mkdir timeout/; fi
	mv `cat timeoutjob.log |  sed 's|$|-err.log|'` timeout/
	mv `cat timeoutjob.log |  sed 's|$|-out.log|'` timeout/
	EXITSTATUS=1
    fi
fi

thereislogfile


if [ ! -e "exitedjob.log" ]; then
    list=`grep -H 'Exited with' *-out.log | cut -d ':' -f 1 | sed 's|-out.log||'`
    if [ -n "$list" ];then
        if [ ! -d "exited" ]; then mkdir exited; fi
        errors="$errors EXITED"
    fi
    for i in $list; do
        dir=`echo $i |sed 's|-[0-9]*$||'`;
        echo filelist/$dir/$i.list >> exitedjob.log
        mv $i-out.log exited/
        mv $i-err.log exited/
    done
fi
thereislogfile

# list of Done job
#echo " Controlling Done jobs"

if [ "`grep -H Done *-out.log | wc -l`" != "0" ]; then
#    echo "  --> Done job found: creating done.log"
    grep -H Done *-out.log | cut -d ':' -f 1  | sed 's|-out.log||' > done.log
    if [ ! -e done ]; then mkdir done; fi
    mv `cat done.log | sed 's|$|-out.log|'` done/
    mv `cat done.log | sed 's|$|-err.log|'` done/
fi

thereislogfile


if [ -z "$errors" ]; then exit 0 ; else 
    echo "Errors in $sample: $errors"; 
    exit 1
fi

# in ultimo tolgo quelli con errori

exit 0

if [ ! -e "errorjob.log" ]; then
    if [ 
    grep -H Error *-err.log | grep castor | cut -d ':' -f 1 | sed 's|-err.log||' > errorjob.log
    mkdir errorjob/
#    mv `cat errorjob.log | sed 's|$|-err.log|'` errorjob/
#    mv `cat errorjob.log | sed 's|$|-out.log|'` errorjob/

fi
exit 0




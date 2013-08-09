#!/bin/bash

# for eos commands
PATH=$PATH:/afs/cern.ch/project/eos/installation/pro/bin/

outputFileList=`ls $local_output_dir`

if [ "`echo ${outputFileList[@]} | sed '/^$/ d' | wc -l`" == "0" ]; then
    echo "[ERROR]::254::No output file generated "  >> /dev/stderr
    exit 254
fi

# select the right command to make the output
case $output_dir in
    *castor*)
	mkdir_="rfmkdir -m 755"
	ls_=rfdir
	cp_=rfcp
            # copio l'output su castor
	;;
    *eos*)
	mkdir_="eos.select mkdir -p"
	ls_="eos.select ls"
	cp_="xrdcp -v -np -f"
	output_dir_prefix="root://eoscms/"
	;;
    *)
	mkdir_=mkdir
	ls_=ls
	cp_=cp
esac

echo "[STATUS] creating remote dir $output_dir/$sample"
# check if the directory already exists
$ls_ $output_dir/$sample &> /dev/null || {
    $mkdir_  $output_dir/$sample || { 
	echo "[ERROR]::5::Impossible to create remote output directory" >> /dev/stderr
	echo "[ERROR]::5::$output_dir/$sample" >> /dev/stderr
	exit 5
    }
}

for outputFile in ${outputFileList[@]}
  do
  ext=`echo $outputFile | sed 's|.*\.||'`
  fname=`basename $outputFile .$ext`
  echo $fname
  echo "renaming file $fname.$ext in: $fname-$index.$ext"
  outputFile=$fname-$index.$ext
  mv $local_output_dir/$fname.$ext $local_output_dir/$outputFile
  echo "[STATUS] copying file $outputFile to: $output_dir/$sample/$outputFile"
  $cp_ $local_output_dir/$outputFile $output_dir_prefix$output_dir/$sample/$outputFile || {
      echo "[ERROR]::6::Copy file error" >> /dev/stderr
  }
done


# clean the local working dir removing output files    
rm $local_output_dir/ -rf

# do not put an exit 0 at the end of this script since it is sourced by other scripts


    

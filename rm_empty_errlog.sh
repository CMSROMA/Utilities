#!/bin/bash
for i_file in `ls *-err.log`; 
  do 
  if [ ! -s $i_file ]; then 
      rm $i_file;
      out_file=`echo $i_file | sed 's|err|out|'`
      rm $out_file;
  fi;
done

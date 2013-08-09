#!/bin/bash

file=$1

cat > remove_dup.awk <<EOF

BEGIN{
  old=0;
  new =0;
  line="";
}

(NR!=0){
  if(match($0,"[0-9]*_[0-9]*_[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]\.root")){ # if the file is a typical castor output
    end=substr($0,RSTART);
    
    n = split(end, end_, "_");
#    print n, $0;
#    print end_[1], end_[2], end_[3];
    if(match(end_[3],"[a-zA-Z]+.*\.root")){ # se soddisfa anche a questa,
                                            # allora e' prodotto da crab server 
      
      if(end_[1]!=old){ 
	print line
	old=end_[1];
	new =end_[2];
	line = $0;
      } else {
	#print end_[1], end_[2], end_[3];
	if(end_[2]>=new){
	  string1="basename "line
	  string2="basename "$0
	  string2 | getline filename_new
	  string1 | getline filename_old
	  print "[STATUS] removing "filename_old" as duplicate of "filename_new"" > "/dev/stderr"
	  new = end_[2];
	  line = $0;
	} 
      } 
    } else print $0
  } else print $0 
}

END{
  if(line!="")  print line

}

EOF

awk -f remove_dup.awk $file | sed '/^$/ d' 
rm remove_dup.awk


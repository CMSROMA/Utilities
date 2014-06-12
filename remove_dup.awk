BEGIN{
  old=0;
  new =0;
  line="";
  dup="";
  fsize_new=-1;
}

(NR!=0){
  if(match($0,"[0-9]*_[0-9]*_[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]\.root")){ # if the file is a typical castor output
    end=substr($1,RSTART);
    start=substr($1,0,RSTART);

    n = split(end, end_, "_");
#    print n, $0 >> "/dev/stderr"
#    print end_[1], end_[2], end_[3], " -- ", $2 >> "/dev/stderr"
    if(match(end_[3],"[a-zA-Z]+.*\.root")){ # se soddisfa anche a questa,
                                            # allora e' prodotto da crab server 
      
      if(end_[1]!=old || start!=old_start){ 
	# print the old line
	print line
	old=end_[1];
	new =end_[2];
	old_start=start;
	line = $0;

	fsize_old=$2
      } else {
	#print end_[1], end_[2], end_[3];
	if(end_[2]>new || $2>fsize_old){
	  string1="basename "line
	  string2="basename "$0
	  string2 | getline filename_new
	  string1 | getline filename_old
	  print "[STATUS] "string1, string2 >> "/dev/stderr"
	  print "[STATUS] removing "filename_old" as duplicate of "filename_new"" >> "/dev/stderr"
	  new = end_[2];
	  line = $0;
	  fsize_old=fsize_new;
	  fsize_new=$2;
	} else{
	  string1="basename "line
	  string2="basename "$0
	  string2 | getline filename_new
	  string1 | getline filename_old
	  print "[STATUS] "string1, string2 >> "/dev/stderr"
	  print "[STATUS] removing "filename_new" as duplicate of "filename_old"" >> "/dev/stderr"
	}	  
      } 
    } else print $0
  } else print $0 
}

END{
  if(line!="")  print line

}

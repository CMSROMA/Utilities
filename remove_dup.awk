BEGIN{
  old=0;
  new =0;
  line="";
  dup="";
}

(NR!=0){
  if(match($0,"[0-9]*_[0-9]*_[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]\.root")){ # if the file is a typical castor output
    end=substr($0,RSTART);
    start=substr($0,0,RSTART);

    n = split(end, end_, "_");
#    print n, $0;
#    print end_[1], end_[2], end_[3];
    if(match(end_[3],"[a-zA-Z]+.*\.root")){ # se soddisfa anche a questa,
                                            # allora e' prodotto da crab server 
      
      if(end_[1]!=old || start!=old_start){ 
	print line
	old=end_[1];
	new =end_[2];
	old_start=start;
	line = $0;
      } else {
	#print end_[1], end_[2], end_[3];
	if(end_[2]>=new){
	  string1="basename "line
	  string2="basename "$0
	  string2 | getline filename_new
	  string1 | getline filename_old
	  print "[STATUS] "string1, string2 >> "/dev/stderr"
	  print "[STATUS] removing "filename_old" as duplicate of "filename_new"" >> "/dev/stderr"
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

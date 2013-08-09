# script di awk per merging di file dati distribuiti in colonne
# questo script effettua il merging di due file che abbiano 
# lo stesso numero di righe

# istruzione:
# awk -f merge.awk -v FILE1=filename1 filename1

BEGIN{
#  system(wc -l FILE)
}

(NF != 0){
    line=$0;
    getline < FILE;
    if(NF!=0){
	line1=$0;}
#  getline < FILE2;
#  line2=$0;
 #   printf("%s\t%s\n", line1, line);
    print line1,"\t", line;
}


END{


}
#!/bin/bash

#entries=yes
n=0;

# $$ rappresenta il PID di questo script e permette la identificazione
# univoca del file err.log generato da questo script 
if [ ! -d "filecheck" ]; then mkdir filecheck/ ;fi

for i in $@; do
    echo "{" > ./filecheck/$$-$n.C
    echo "TFile::Open(\"$i\");" >> ./filecheck/$$-$n.C
    echo "Long64_t entries = ntp1->GetEntries();" >> ./filecheck/$$-$n.C
    echo "if (entries ==0) std::cerr << \"Error: no entries\" << std::endl;" >> ./filecheck/$$-$n.C
    echo "}" >> ./filecheck/$$-$n.C
    root -l -b -q ./filecheck/$$-$n.C 2> ./filecheck/err-$$-$n.log
#    echo "rfio:$i" | xargs -i root -l -b -q {} 2> err-$$-$n.log
    if [ "`grep -c Error ./filecheck/err-$$-$n.log`" != "0" -o "`grep -c Break ./filecheck/err-$$-$n.log`" != "0" ];then
	echo "$i" >> failed_check.list
    fi
    let n=$n+1;
#    rm $$-$n.C
done



    

#!/bin/bash
rfdir $@ | awk '(NF!=0){print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5/1024/1024 " MB\t" $6 "\t" $7 "\t" $8 "\t" $9}'

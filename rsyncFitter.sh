#!/bin/bash

usage(){
    echo "Usage: `basename $0` <-l|-t|-m|-d>" 
    echo "        -m: MC to tmp"
    echo "        -d: data to tmp"
    echo "        -t: MC and data to tmp"
    echo "        -l: tmp to local"

}


case $# in 
    0)
	usage
	exit 1
	;;
    1)
	;;
    *)
	usage 
	exit 1
	;;
esac

EXCLUDE="--exclude=*.root"
while getopts htlmd option
  do
  case $option in
      h)
	  usage
	  exit 0
	  ;;
      m)
	  rsync -ahuvz test/MC/ lxplus:/tmp/shervin/test/MC/
	  ;;
      t)
	  rsync -ahuvz test/MC/ lxplus:/tmp/shervin/test/MC/
	  rsync -ahuvz test/data/ lxplus:/tmp/shervin/test/data/
	  ;;
      d)
	  rsync -ahuvz test/data/ lxplus:/tmp/shervin/test/data/
	  ;;
      l)
	  rsync -ahuvz lxplus309:/tmp/shervin/test/MC/ test/MC/ 
	  ;;
#	  rsync -ahuvz $EXCLUDE lxplus:~/scratch1/analyzer/ /home/CMS/results/analyzer/
#	  ;;
      *)
	  echo "[ERROR] Wrong parameter" >> /dev/stderr
	  usage >> /dev/stderr
	  exit 1
	  ;;
  esac
done

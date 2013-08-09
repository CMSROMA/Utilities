#!/bin/bash
usage(){
    echo "Usage: `basename $0` castor_dir" > /dev/stderr
	}
    
case $# in 
    0)
    usage
    exit 1
    ;;
    *)
    ;;
esac


rfdir.sh | awk '{print $10}'
exit 0

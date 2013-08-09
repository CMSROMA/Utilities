#!/bin/bash

usage(){
    echo "Usage: `basename $0` old_json new_json" > /dev/stderr
}

case $# in 
    2)
	old_json=$1;
	new_json=$2;
	;;
    *)
	echo -n "Error. " > /dev/stderr
	usage
	;;
esac

if [ ! -r "$old_json" ]; then 
    echo "Error. $old_json file not found or not readable" > /dev/stderr
fi

if [ ! -r "$new_json" ]; then 
    echo "Error. $new_json file not found or not readable" > /dev/stderr
fi

sed 's|, \"|, \n|g' $old_json > /tmp/old.json
echo >> /tmp/old.json

sed 's|, \"|, \n|g' $new_json > /tmp/new.json
echo >> /tmp/new.json

echo "< = old; > = new"
diff /tmp/old.json /tmp/new.json

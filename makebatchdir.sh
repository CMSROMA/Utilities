#!/bin/bash

echo "[INFO] Creating and preparing batch subdir"

# creo la cartella
mkdir batch/

# creo il il base_script
base=./batch/base_script

cat > $base <<EOF
#!/bin/bash
# this is the directory from which the job has been launched
cd $PWD
export SCRAM_ARCH=$SCRAM_ARCH
eval \`scramv1 runtime -sh\`
# return to the working dir on the batch machine
cd -
cp $PWD/batch/$analysis.tar ./
tar -xf $analysis.tar
mkdir -p ./output
# do not put exit 0 at the end of the script since it is sourced by other scripts
EOF


if [ ! -e "$HOME/bin/base_output.sh" ];then
    echo "base_output.sh not found in $HOME/bin/" > /dev/stderr
    echo "please ask shervin@cern.ch the base_output.sh file" > /dev/stderr
    exit 1
fi

cp $HOME/bin/base_output.sh ./batch/

# copy the launching script in the batch directory
cp ./script/start.sh ./batch/
# copy the analysis script to be executed on the batch host
cp ./script/$analysis.sh ./batch/



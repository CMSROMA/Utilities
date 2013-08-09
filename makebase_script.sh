#!/bin/bash
analysis=`basename $PWD`
CMSSW_version=CMSSW_3_3_6
local_output=./output

echo "#!/bin/bash"                                                > ./batch/base_script
echo "export X509_USER_PROXY=/afs/cern.ch/user/s/shervin/gpi.out" >> ./batch/base_script
echo "cd /afs/cern.ch/user/s/shervin/$CMSSW_version"              >> ./batch/base_script
echo "eval \`scramv1 runtime -sh\`"                               >> ./batch/base_script
echo "cd -"                                                       >> ./batch/base_script
echo "cp $PWD/batch/$analysis.tar ./"                             >> ./batch/base_script
echo "tar -xf $analysis.tar"                                      >> ./batch/base_script
echo "mkdir -p $local_output/"                                    >> ./batch/base_script


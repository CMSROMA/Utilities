# versione2
source /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env.sh
cmsenv
source /afs/cern.ch/cms/ccs/wm/scripts/Crab/crab.sh
voms-proxy-init -voms cms -out $HOME/gpi.out
echo "crab -create -submit -cfg crab.cfg"
echo "crab -status"


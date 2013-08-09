#!/bin/bash

# this script analyze the ntuple finding if there are duplicated events
file=$1

treeName=selected
eventNumberBranch=eventNumber
lumiSectionBranch=lumiBlock
runNumberBranch=runNumber

cat > dupmacro.C <<EOF
{
  $treeName->SetScanField(0);
  $treeName->Scan("$runNumberBranch:$eventNumberBranch", "","colsize=10 col=%ld:%ld"); > scan.log
}
EOF

root -l -b -q $file dupmacro.C
#rm dupmacro.C
sort scan.log > sort.log
rm scan.log
uniq -d sort.log


exit 0
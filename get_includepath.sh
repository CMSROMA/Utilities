#!/bin/bash
echo "{" > include/include_path.C
echo "  gROOT->ProcessLine(\".include $INCLUDE_ROOFIT\");" >> include/include_path.C
echo "}" >> include/include_path.C

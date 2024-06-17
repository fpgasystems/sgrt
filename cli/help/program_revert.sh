#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

echo "" #this one is needed
echo "${bold}sgutil program revert [flags] [--help]${normal}"
echo ""
echo "Returns the specified FPGA to the Vitis workflow."
echo ""
echo "FLAGS:"
echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
echo ""
echo "   -h, --help      - Help to revert a device."
echo ""
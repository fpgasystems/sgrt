#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo "" #this one is needed
echo "${bold}$CLI_NAME program revert [flags] [--help]${normal}"
echo ""
echo "Returns the specified FPGA to the Vitis workflow."
echo ""
echo "FLAGS:"
echo "   -d, --device    - FPGA Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo ""
echo "   -h, --help      - Help to revert a device."
echo ""
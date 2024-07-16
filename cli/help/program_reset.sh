#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME program reset [flags] [--help]${normal}"
echo ""
echo "Resets a given FPGA/ACAP."
echo ""
echo "FLAGS:"
echo "   -d, --device    - FPGA Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
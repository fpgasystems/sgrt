#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

ONIC_SHELL_COMMIT=$1
ONIC_DRIVER_COMMIT=$2

#echo ""
echo "${bold}sgutil validate opennic [flags] [--help]${normal}"
echo ""
echo "Validates OpenNIC on the selected FPGA."
echo ""
echo "FLAGS:"
echo "   -c, --commit    - GitHub commit IDs for shell and driver (default: ${bold}$ONIC_SHELL_COMMIT,$ONIC_DRIVER_COMMIT${normal})."
echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
exit 1
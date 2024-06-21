#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_SHELL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_REPO)

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
#exit 1
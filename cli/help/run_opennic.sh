#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)

echo ""
echo "${bold}$CLI_NAME run opennic [flags] [--help]${normal}"
echo ""
echo "Runs OpenNIC on a given FPGA."
echo ""
echo "FLAGS:"
echo "   -c, --commit    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
echo "   -d, --device    - FPGA Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   -p, --project   - Specifies your OpenNIC project name."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
#exit 1
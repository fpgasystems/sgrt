#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)

echo ""
echo "${bold}$CLI_NAME validate opennic [flags] [--help]${normal}"
echo ""
echo "Validates OpenNIC on an adaptive device."
echo ""
echo "FLAGS:"
echo "   -c, --commit    - GitHub shell and driver commit IDs (default: ${bold}$ONIC_SHELL_COMMIT,$ONIC_DRIVER_COMMIT${normal})."
echo "   -d, --device    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   -f, --fec       - Enables or disables RS-FEC encoding."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
#exit 1
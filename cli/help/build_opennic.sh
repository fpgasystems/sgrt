#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)

echo ""
echo "${bold}$CLI_NAME build opennic [flags] [--help]${normal}"
echo ""
echo "Generates OpenNIC's bitstreams and drivers."
echo ""
echo "FLAGS:"
echo "       --commit    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
echo "       --config    - Configuration index."
echo "       --platform  - Xilinx platform (according to ${bold}$CLI_NAME get platform${normal})."
echo "       --project   - Specifies your OpenNIC project name."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
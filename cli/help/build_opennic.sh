#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)

#echo ""
echo "${bold}sgutil build opennic [flags] [--help]${normal}"
echo ""
echo "Generates OpenNIC's bitstreams and drivers."
echo ""
echo "FLAGS:"
echo "   -c, --commit    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
echo "       --platform  - Xilinx platform (according to sgutil get platform)."
echo "       --project   - Specifies your Coyote project name."
echo ""
echo "   -h, --help      - Help to build OpenNIC."
echo ""
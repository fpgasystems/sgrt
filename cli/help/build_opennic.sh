#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
is_acap=$3
is_cpu=$4 
is_fpga=$5

ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)

if [ "$is_acap" = "1" ] || [ "$is_cpu" = "1" ] || [ "$is_fpga" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build opennic [flags] [--help]${normal}"
    echo ""
    echo "Generates OpenNIC's bitstreams and drivers."
    echo ""
    echo "FLAGS:"
    echo "   -c, --commit    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
    if [ "$is_cpu" = "1" ]; then
    echo "       --platform  - Xilinx platform (according to ${bold}$CLI_NAME get platform${normal})."
    fi
    echo "       --project   - Specifies your OpenNIC project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
fi
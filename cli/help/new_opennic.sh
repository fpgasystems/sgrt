#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
is_acap=$3
is_fpga=$4 
is_vivado_developer=$5

#constants
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)

if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
    echo ""
    echo "${bold}$CLI_NAME new opennic [flags] [--help]${normal}"
    echo ""
    echo "Smart Network Interface Card (SmartNIC) applications with OpenNIC."
    echo ""
    echo "FLAGS:"
    echo "   -c, --commit    - GitHub shell and driver commit IDs (default: ${bold}$ONIC_SHELL_COMMIT,$ONIC_DRIVER_COMMIT${normal})."
    echo "       --project   - Specifies your OpenNIC project name." 
    echo "       --push      - Pushes your OpenNIC project to your GitHub account." 
    echo ""
    echo "   -h, --help      - Help to use this command."
    #echo ""
    #exit 1
fi
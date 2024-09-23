#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
is_acap=$3
is_build=$4 
is_fpga=$5

ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)

COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

if [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; then
    echo ""
    echo -e "${bold}${COLOR_ON2}$CLI_NAME build opennic [flags] [--help]${COLOR_OFF}${normal}"
    echo ""
    echo -e "${COLOR_ON2}Generates OpenNIC's bitstreams and drivers.${COLOR_OFF}"
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-c, --commit${normal}    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
    if [ "$is_build" = "1" ]; then
    echo "       ${bold}--platform${normal}  - Xilinx platform (according to ${bold}$CLI_NAME get platform${normal})."
    fi
    echo "       ${bold}--project${normal}   - Specifies your OpenNIC project name."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "0" "1" "0"
    echo ""
fi
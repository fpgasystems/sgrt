#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_build=$2
is_gpu=$3 

COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
    echo ""
    echo -e "${bold}${COLOR_ON5}$CLI_NAME build hip [flags] [--help]${COLOR_OFF}${normal}"
    echo ""
    echo -e "${COLOR_ON5}Generates HIP binaries for your projects.${COLOR_OFF}"
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-p, --project${normal}   - Specifies your HIP project name."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1"
    echo ""
fi
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_cpu=$2
is_gpu=$3 

COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

# Trim any whitespace or newline from the values of is_cpu and is_gpu
is_cpu=$(echo "$is_cpu" | tr -d '[:space:]')
is_gpu=$(echo "$is_gpu" | tr -d '[:space:]')

if [ "$is_cpu" = "1" ] || [ "$is_gpu" = "1" ]; then
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
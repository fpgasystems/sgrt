#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CLI_NAME=$1
is_acap=$2
is_build=$3
is_fpga=$4
is_gpu=$5
is_gpu_developer=$6
is_vivado_developer=$7

#legend
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#evaluate integrations
gpu_enabled=$([ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)

#print help
echo ""
echo "${bold}$CLI_NAME build [arguments [flags]] [--help]${normal}"
echo ""
echo "Creates binaries, bitstreams, and drivers for your accelerated applications."
echo ""
echo "ARGUMENTS:"
echo "   ${bold}c${normal}               - Generates C and C++ binaries."
if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON5}hip${normal}${COLOR_OFF}             - Generates HIP binaries for your projects."  
fi
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Generates OpenNIC's bitstreams and drivers."
fi
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
$CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "0" "$is_vivado_developer" "$is_gpu_developer"
echo ""
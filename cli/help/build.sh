#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_acap=$2
is_build=$3
is_fpga=$4
is_gpu=$5
is_vivado_developer=$6

COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#list of non vivado build commands (*)
build_commands="c"

#print help
echo ""
echo "${bold}$CLI_NAME build [arguments [flags]] [--help]${normal}"
echo ""
echo "Creates binaries, bitstreams, and drivers for your accelerated applications."
echo ""
echo "ARGUMENTS:"
echo "   ${bold}c${normal}               - Generates C and C++ binaries."
if                         [ "$is_build" = "1" ] ||                         [ "$is_gpu" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON5}hip${normal}${COLOR_OFF}             ${COLOR_ON5}- Generates HIP binaries for your projects.${COLOR_OFF}"  
fi
if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
    echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         ${COLOR_ON2}- Generates OpenNIC's bitstreams and drivers.${COLOR_OFF}"
    build_commands="${build_commands} opennic"
fi
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""

#get number of build commands
build_commands_array=($build_commands)
num_elements=${#build_commands_array[@]}

#legend
if [ "$num_elements" -gt "1" ]; then # the comparison value represents the number of elements in (*)
    if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
        "$CLI_PATH/common/print_legend" "$CLI_PATH" "$CLI_NAME" "$is_acap" "0" "$is_fpga" "$is_gpu"
    elif [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        "$CLI_PATH/common/print_legend" "$CLI_PATH" "$CLI_NAME" "$is_acap" "0" "$is_fpga" "0"
    fi
    echo ""
fi
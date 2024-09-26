#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_acap=$2
is_build=$3
is_fpga=$4
is_gpu=$5
is_gpu_developer="1"
is_vivado_developer=$6

COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#list of non vivado build commands (*)
#build_commands="c"

#integrations
#gpu_enabled="0"
#vivado_enabled="0"

#evaluate integrations
gpu_enabled=$($CLI_PATH/common/is_enabled "gpu" $is_acap $is_fpga $is_gpu $is_gpu_developer $is_vivado_developer)
vivado_enabled=$($CLI_PATH/common/is_enabled "vivado" $is_acap $is_fpga $is_gpu $is_gpu_developer $is_vivado_developer)

#print help
echo ""
echo "${bold}$CLI_NAME build [arguments [flags]] [--help]${normal}"
echo ""
echo "Creates binaries, bitstreams, and drivers for your accelerated applications."
echo ""
echo "ARGUMENTS:"
echo "   ${bold}c${normal}               - Generates C and C++ binaries."
#if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
if [ "$is_gpu_developer" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON5}hip${normal}${COLOR_OFF}             - Generates HIP binaries for your projects."  
    #gpu_enabled="1"
fi
#if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
if [ "$is_vivado_developer" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Generates OpenNIC's bitstreams and drivers."
    #vivado_enabled="1"
fi
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""



#legend
#if [ "$is_build" = "1" ]; then
    $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "0" "$is_vivado_developer" "$is_gpu_developer"
#else
#    $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "0" "$vivado_enabled" "$gpu_enabled"
#fi
echo ""

#if [ "$gpu_enabled" = "1" ] && [ "$vivado_enabled" = "1" ]; then
#    if [ "$is_build" = "1" ]; then
#        $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "1" "1" "1"
#    else
#        $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "$is_acap" "$is_fpga" "$is_gpu"
#    fi
#    #echo ""
#elif [ "$gpu_enabled" = "0" ] && [ "$vivado_enabled" = "1" ]; then
#    if [ "$is_build" = "1" ]; then
#        $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "1" "1" "0"
#    else
#        $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "$is_acap" "$is_fpga" "0"
#    fi
#    #echo ""
#elif [ "$gpu_enabled" = "1" ] && [ "$vivado_enabled" = "0" ]; then
#    if [ "$is_build" = "1" ]; then
#        $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "0" "0" "1"
#    else
#        $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "0" "0" "1"
#    fi
#    #echo ""
#fi
#echo ""
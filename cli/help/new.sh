#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
parameter=$3
is_acap=$4
is_cpu=$5
is_fpga=$6
is_gpu=$7
is_vivado_developer=$8

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

if [ "$parameter" = "--help" ]; then
    echo ""
    echo "${bold}$CLI_NAME new [arguments] [--help]${normal}"
    echo ""
    echo "Creates a new project of your choice."
    echo ""
    echo "ARGUMENTS:"
    if [ "$is_gpu" = "1" ] || [ "$is_fpga" = "1" ]; then
    echo -e "   ${COLOR_ON5}hip${COLOR_OFF}             - Portable single-source ROCm applications for GPUs."
    fi
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
    echo -e "   ${COLOR_ON2}opennic${COLOR_OFF}         - Smart Network Interface Card (SmartNIC) applications with OpenNIC."
    fi
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
elif [ "$parameter" = "hip" ]; then
    if [ "$is_gpu" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME new hip [--help]${normal}"
    echo ""
    echo "Portable single-source ROCm applications for GPUs."
    echo ""
    echo "FLAGS"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    fi
elif [ "$parameter" = "opennic" ]; then
    $CLI_PATH/help/new_opennic $CLI_PATH $CLI_NAME
    echo ""
fi

#print legend
$CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_cpu $is_fpga $is_gpu
echo ""
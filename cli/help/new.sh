#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
parameter=$3
is_acap=$4
is_build=$5
is_fpga=$6
is_gpu=$7
is_vivado_developer=$8

#constants
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)

#evaluate integrations
gpu_integrations=$($CLI_PATH/common/enable_integrations "build_gpu" $is_acap $is_build $is_fpga $is_gpu $is_vivado_developer)
vivado_integrations=$($CLI_PATH/common/enable_integrations "build_vivado" $is_acap $is_build $is_fpga $is_gpu $is_vivado_developer)

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#so far the only integrations are GPU or Vivado
if [ "$gpu_integrations" = "1" ] || [ "$vivado_integrations" = "1" ]; then
    if [ "$parameter" = "--help" ]; then
        echo ""
        echo "${bold}$CLI_NAME new [arguments] [--help]${normal}"
        echo ""
        echo "Creates a new project of your choice."
        echo ""
        echo "ARGUMENTS:"
        if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON5}hip${COLOR_OFF}${normal}             - Portable single-source ROCm applications."
        fi
        if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
        echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Smart Network Interface Card (SmartNIC) applications with OpenNIC."
        fi
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        if [ "$gpu_integrations" = "1" ] && [ "$vivado_integrations" = "1" ]; then
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1"
        elif [ "$gpu_integrations" = "1" ]; then
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "1"
        elif [ "$vivado_integrations" = "1" ]; then
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "0"
        fi        
        echo ""
    elif [ "$parameter" = "hip" ]; then
        if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new hip [--help]${normal}"
            echo ""
            echo "Portable single-source ROCm applications."
            echo ""
            echo "FLAGS"
            echo "   This command has no flags."
            echo ""
            echo "   -h, --help      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "1" "yes"
            echo ""
        fi
    elif [ "$parameter" = "opennic" ]; then
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
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "0" "yes"
            echo ""
        fi
    fi
fi
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
is_acap=$3
is_cpu=$4
is_fpga=$5
is_gpu=$6

#get colors
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)


if [ "$is_cpu" = "1" ]; then
echo -e "                     ${COLOR_ON1}CPUs${COLOR_OFF}"
elif ([ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]) && [ "$is_gpu" = "1" ]; then
echo -e "                     ${COLOR_ON2}Adaptive Devices ${COLOR_ON1}CPUs ${COLOR_ON5}GPUs${COLOR_OFF}"
elif [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
echo -e "                     ${COLOR_ON2}Adaptive Devices ${COLOR_ON1}CPUs${COLOR_OFF}"
elif [ "$is_gpu" = "1" ]; then
echo -e "                     ${COLOR_ON1}CPUs ${COLOR_ON5}GPUs${COLOR_OFF}"
fi
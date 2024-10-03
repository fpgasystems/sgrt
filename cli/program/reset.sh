#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program reset --device $device_index --version $vivado_version
#example: /opt/sgrt/cli/sgutil program reset --device             1 --version          2022.2

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$($CLI_PATH/common/is_enabled "vivado" $is_acap $is_fpga $is_gpu $IS_GPU_DEVELOPER $is_vivado_developer)
if [ "$vivado_enabled" = "0" ]; then
    exit
fi

#inputs
device_index=$2
vivado_version=$4

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$vivado_version" = "" ]; then
    exit
fi

#constants
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)

#get workflow (print echo)
workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)

#revert
#if [ ! "$workflow" = "vitis" ]; then
#    #echo "${bold}$CLI_NAME program revert${normal}"    
#    #echo ""
#    echo ""Please, revert your device first.""
#    echo ""
#    exit
#fi
#$CLI_PATH/program/revert -d $device_index --version $vivado_version
#if [[ "$workflow" = "vivado" ]]; then
#    echo ""
#fi

#get BDF (i.e., Bus:Device.Function) 
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
bdf="${upstream_port%?}1"

#reset device (we delete any xclbin) assuming xx:xx.1 (bdf) function is present after revert
$XRT_PATH/bin/xbutil reset --device $bdf --force

echo ""
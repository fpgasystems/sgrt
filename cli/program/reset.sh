#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/program/reset --device $device_index --version $vivado_version
#example: /opt/sgrt/cli/program/reset --device             1 --version          2022.2

#inputs
device_index=$2
vivado_version=$4

#constants
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)

#get workflow (print echo)
workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)

#revert
if [[ "$workflow" = "vivado" ]]; then
    echo "${bold}$CLI_NAME program revert${normal}"    
    echo ""
fi
$CLI_PATH/program/revert -d $device_index --version $vivado_version
if [[ "$workflow" = "vivado" ]]; then
    echo ""
fi

#get BDF (i.e., Bus:Device.Function) 
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
bdf="${upstream_port%?}1"

#reset device (we delete any xclbin) assuming xx:xx.1 (bdf) function is present after revert
$XRT_PATH/bin/xbutil reset --device $bdf --force

echo ""
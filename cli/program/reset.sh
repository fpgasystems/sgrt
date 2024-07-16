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
#DEVICES_LIST="$CLI_PATH/devices_acap_fpga"

#get hostname
#url="${HOSTNAME}"
#hostname="${url%%.*}"

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA)
#acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
#    echo ""
#    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
#    echo ""
#    exit
#fi

#check on valid XRT version
#if [ ! -d $XRT_PATH ]; then
#    echo ""
#    echo "Please, source a valid XRT and Vitis version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on valid XRT and Vivado version
#xrt_version=$($CLI_PATH/common/get_xilinx_version xrt)

#if [ -z "$xrt_version" ]; then #if [ -z "$(echo $xrt_version)" ]; then
#    echo ""
#    echo "Please, source a valid XRT version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on DEVICES_LIST
#source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
#MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

#check on multiple devices
#multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

# inputs
#read -a flags <<< "$@"

#echo ""
#echo "${bold}sgutil program reset${normal}"

#check on flags
#device_found=""
#device_index=""
#if [ "$flags" = "" ]; then
#    #device_dialog
#    if [[ $multiple_devices = "0" ]]; then
#        device_found="1"
#        device_index="1"
#    else
#        echo ""
#        echo "${bold}Please, choose your device:${normal}"
#        echo ""
#        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
#        device_found=$(echo "$result" | sed -n '1p')
#        device_index=$(echo "$result" | sed -n '2p')
#    fi
#else
#    #device_dialog_check
#    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
#    device_found=$(echo "$result" | sed -n '1p')
#    device_index=$(echo "$result" | sed -n '2p')
#    #forbidden combinations
#    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
#        $CLI_PATH/sgutil program reset -h
#        exit
#    fi
#    #device_dialog (forgotten mandatory)
#    if [[ $multiple_devices = "0" ]]; then
#        device_found="1"
#        device_index="1"
#    elif [[ $device_found = "0" ]]; then
#        $CLI_PATH/sgutil program reset -h
#        exit
#    fi
#fi

#vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)

#get workflow (print echo)
workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)

#revert
if [[ "$workflow" = "vivado" ]]; then
    echo ""
    echo "${bold}$CLI_NAME program revert${normal}"    
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
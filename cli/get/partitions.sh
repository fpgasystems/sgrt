#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil get partitions --device $device_index
#example: /opt/sgrt/cli/sgutil get partitions --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
#is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
#vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_asoc" = "0" ]; then
    exit
fi

echo "Hey I am here"


#inputs
device_index=$2

#constants
#AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
#AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
#AVED_UUID=$($CLI_PATH/common/get_constant $CLI_PATH AVED_UUID)
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
TYPE="primary"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

#all inputs must be provided
if [ "$device_index" = "" ]; then
    echo ""
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        partitions=""
        if [ "$device_type" = "asoc" ]; then
            upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
            partitions=$(ami_tool cfgmem_info -d $upstream_port -t $TYPE | awk '/^Partition/ {flag=1; next} flag && /^[0-9]/' | wc -l)
            partitions=$((partitions - 1))
            #print
            echo "$device_index: 0 ... $partitions"
        else
            #print
            echo "$device_index: "
        fi
    done
    echo ""
else
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
    partitions=$(ami_tool cfgmem_info -d $upstream_port -t $TYPE | awk '/^Partition/ {flag=1; next} flag && /^[0-9]/' | wc -l)
    partitions=$((partitions - 1))
    #print
    echo "$device_index: 0 ... $partitions"
fi

#exit

#author: https://github.com/jmoya82
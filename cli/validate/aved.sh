#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil validate aved --device $device_index
#example: /opt/sgrt/cli/sgutil validate aved --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
#is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
#is_virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$vivado_enabled_asoc" = "0" ]; then
    exit
fi

#inputs
device_index=$2

#all inputs must be provided
if [ "$device_index" = "" ]; then
    exit
fi

#get device_name
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

echo "upstream_port: $upstream_port"

#ami_tool validation
ami_tool overview
ami_tool mfg_info -d $upstream_port

#xbtest validation
xbtest -d $upstream_port -c verify
xbtest -d $upstream_port -c memory

echo ""

#author: https://github.com/jmoya82
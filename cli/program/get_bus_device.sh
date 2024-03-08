#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#inputs
device_index=$1
parameter=$2

#declare global variables
declare -g bus_device=""

#get upstream_port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#transform to bus_device (from a1:00.0 to a1_00)
bus_device=$(echo "$upstream_port" | sed 's/:/_/;s/\..*//')

bus="${bus_device%_*}"  # Extracts the substring before the underscore
device="${bus_device#*_}"  # Extracts the substring after the underscore

#return the value
if [[ $parameter = "bus" ]]; then
    bus_device=$bus
elif [[ $parameter = "device" ]]; then
    bus_device=$device
fi
echo "$bus_device"
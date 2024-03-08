#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#inputs
device_index=$1

#get bus and device
bus=$($CLI_PATH/program/get_bus_device $device_index bus)
device=$($CLI_PATH/program/get_bus_device $device_index device)

#get N_REGIONS
N_REGIONS=$(cat /sys/kernel/coyote_sysfs_${bus}_${device}/cyt_attr_cnfg | grep vFPGA | awk -F': ' '{print $2}')

#apply fpga_chmod to N_REGIONS
echo "${bold}Enabling vFPGA regions:${normal}"
echo ""
$CLI_PATH/program/enable_regions ${bus}_${device} $N_REGIONS
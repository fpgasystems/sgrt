#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"

#inputs
#DIR=$1
device_index=$1
#N_REGIONS=$3

#get upstream_port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#transform to bus_device (from a1:00.0 to a1_00)
bus_device=$(echo "$upstream_port" | sed 's/:/_/;s/\..*//')

#get N_REGIONS
N_REGIONS=$(cat /sys/kernel/coyote_sysfs_$bus_device/cyt_attr_cnfg | grep vFPGA | awk -F': ' '{print $2}')

##get N_REGIONS
#line=$(grep -n "N_REGIONS" $DIR/configs/config_shell_static)
##find equal (=)
#idx=$(sed 's/ /\n/g' <<< "$line" | sed -n "/=/=")
##get index
#value_idx=$(($idx+1))
##get data
#N_REGIONS=$(echo $line | awk -v i=$value_idx '{ print $i }' | sed 's/;//' )

#apply fpga_chmod to N_REGIONS
echo "${bold}Enabling vFPGA regions:${normal}"
echo ""
$CLI_PATH/program/enable_regions $bus_device $N_REGIONS
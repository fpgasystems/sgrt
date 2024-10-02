#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil set mtu --interface $interface_name --value $mtu_value
#example: /opt/sgrt/cli/sgutil set mtu --interface       enp35s0f0 --value       1982

#inputs
interface_name=$2
mtu_value=$4

#constants
MTU_MAX=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MAX)
MTU_MIN=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MIN)

calculate_closest_mtu() {
    local desired_mtu=$1
    local header_size=$2
    local base=$3

    # Calculate the closest multiple of 64
    local closest_mtu=$(( ((desired_mtu - header_size) + base - 1) / base * base ))
    local closest_mtu=$(( closest_mtu + header_size ))

    echo $closest_mtu
}

#constants
IPV6_HEADER_SIZE=40
PAYLOAD_MULTIPLES=64

#get closest MTU for a payload multiple
mtu_value=$(calculate_closest_mtu $mtu_value $IPV6_HEADER_SIZE $PAYLOAD_MULTIPLES)

#verify MTU is between valid range
if [ "$mtu_value" -lt "$MTU_MIN" ] || [ "$mtu_value" -gt "$MTU_MAX" ]; then
    exit
fi

#set mtu_value
sudo ifconfig $interface_name mtu $mtu_value up

#print message
echo ""
echo "$interface_name MTU was set to $mtu_value bytes!"
echo ""
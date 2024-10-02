#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil set mtu --interface $interface_name --value $mtu_value
#example: /opt/sgrt/cli/sgutil program opennic --commit   8077751 --device             1 --project   hello_world --remote              0 --version          2022.1

#inputs
interface_name=$2
mtu_value=$4

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
#MTU_MIN=1500
#MTU_MAX=9000
#MTU_DEFAULT=1576 # (1576 - 40) / 64 = 24
#CHECK_ON_MTU_ERR_MSG="Please, choose a valid MTU value."
IPV6_HEADER_SIZE=40
#MTU_DEFAULT=$($CLI_PATH/common/get_constant $CLI_PATH MTU_DEFAULT)
#MTU_MAX=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MAX)
#MTU_MIN=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MIN)
#NETWORKING_DEVICES_LIST="$CLI_PATH/devices_network"
#NETWORKING_DEVICE_INDEX="1"
#NETWORKING_PORT_INDEX="1"
PAYLOAD_MULTIPLES=64

#get devices number
#if [ -s "$NETWORKING_DEVICES_LIST" ]; then
#  source "$CLI_PATH/common/device_list_check" "$NETWORKING_DEVICES_LIST"
#fi

#get hostname
#url="${HOSTNAME}"
#hostname="${url%%.*}"

#get username
#username=$USER

#check for vivado_developers
#member=$($CLI_PATH/common/is_member $USER vivado_developers)
#if [ "$member" = "0" ]; then
#    echo ""
#    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
#    echo ""
#    exit
#fi

#inputs
#read -a flags <<< "$@"

#check on flags
#mtu_found="0"
#mtu_value=""
#if [ "$flags" = "" ]; then
#    $CLI_PATH/sgutil set mtu -h
#    exit
#else
#    if [[ " ${flags[0]} " =~ " -v " ]] || [[ " ${flags[0]} " =~ " --value " ]]; then
#        mtu_found="1"
#        mtu_value=${flags[1]}
#    fi
#fi

#forbidden combinations
#if [ "$mtu_found" = "1" ] && [ "$mtu_value" = "" ]; then
#    #$CLI_PATH/sgutil set mtu -h
#    #exit
#    echo ""
#    echo "$CHECK_ON_MTU_ERR_MSG"
#    echo ""
#    exit
#fi

# Check if MTU_VALUE is a valid integer and within the valid range
#if ! [[ "$mtu_value" =~ ^[0-9]+$ ]] || [ "$mtu_value" -lt "$MTU_MIN" ] || [ "$mtu_value" -gt "$MTU_MAX" ]; then
#    echo ""
#    echo "$CHECK_ON_MTU_ERR_MSG"
#    echo ""
#    exit
#fi

#if [ "$mtu_found" = "1" ]; then
    #get closest MTU for a payload multiple
    mtu_value=$(calculate_closest_mtu $mtu_value $IPV6_HEADER_SIZE $PAYLOAD_MULTIPLES)

    #verify MTU is between valid range
    if [ "$mtu_value" -lt "$MTU_MIN" ] || [ "$mtu_value" -gt "$MTU_MAX" ]; then
        #mtu_value=$MTU_DEFAULT
        exit
    fi

    #get Mellanox name
    #mellanox_name=$(nmcli dev | grep mellanox-0 | awk '{print $1}')
    #mellanox_name=$($CLI_PATH/get/get_nic_config $NETWORKING_DEVICE_INDEX $NETWORKING_PORT_INDEX DEVICE)

    #set mtu_value
    sudo ifconfig $interface_name mtu $mtu_value up

    #print message
    echo ""
    echo "$interface_name MTU was set to $mtu_value bytes!"
    echo ""
#fi
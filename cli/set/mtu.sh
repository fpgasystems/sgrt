#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
MTU_MIN=1500
MTU_MAX=9000
MTU_DEFAULT=1576 # (1576 - 40) / 64 = 24
IPV6_HEADER_SIZE=40
PAYLOAD_MULTIPLES=64
CHECK_ON_MTU_ERR_MSG="Please, choose a valid MTU value."

#get hostname
#url="${HOSTNAME}"
#hostname="${url%%.*}"

#get username
#username=$USER

calculate_closest_mtu() {
    local desired_mtu=$1
    local header_size=$2
    local base=$3

    # Calculate the closest multiple of 64
    local closest_mtu=$(( ((desired_mtu - header_size) + base - 1) / base * base ))
    local closest_mtu=$(( closest_mtu + header_size ))

    echo $closest_mtu
}

#check for vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "0" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#inputs
read -a flags <<< "$@"

#check on flags
mtu_found="0"
mtu_value=""
if [ "$flags" = "" ]; then
    $CLI_PATH/sgutil set mtu -h
    exit
else
    if [[ " ${flags[0]} " =~ " -v " ]] || [[ " ${flags[0]} " =~ " --value " ]]; then
        mtu_found="1"
        mtu_value=${flags[1]}
    fi
fi

#forbidden combinations
if [ "$mtu_found" = "1" ] && [ "$mtu_value" = "" ]; then
    #$CLI_PATH/sgutil set mtu -h
    #exit
    echo ""
    echo "$CHECK_ON_MTU_ERR_MSG"
    echo ""
    exit
fi

# Check if MTU_VALUE is a valid integer and within the valid range
if ! [[ "$mtu_value" =~ ^[0-9]+$ ]] || [ "$mtu_value" -lt "$MTU_MIN" ] || [ "$mtu_value" -gt "$MTU_MAX" ]; then
    echo ""
    echo "$CHECK_ON_MTU_ERR_MSG"
    echo ""
    exit
fi

if [ "$mtu_found" = "1" ]; then
    #get closest MTU for a payload multiple
    mtu_value=$(calculate_closest_mtu $mtu_value $IPV6_HEADER_SIZE $PAYLOAD_MULTIPLES)

    #verify MTU is between valid range
    if [ "$mtu_value" -lt "$MTU_MIN" ] || [ "$mtu_value" -gt "$MTU_MAX" ]; then
        mtu_value=$MTU_DEFAULT
    fi

    #get Mellanox name
    mellanox_name=$(nmcli dev | grep mellanox-0 | awk '{print $1}')

    #set mtu_value
    sudo ifconfig $mellanox_name mtu $mtu_value up

    #print message
    echo ""
    echo "$mellanox_name MTU was set to $mtu_value bytes!"
    echo ""
fi
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
MTU_MIN=1500
MTU_MAX=9000
MTU_DEFAULT=1576
IPV6_HEADER_SIZE=40
PAYLOAD_MULTIPLES=64

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
if [ "$member" = "false" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#inputs
read -a flags <<< "$@"

#check on flags
mtu_valid="0"
if [ "$flags" = "" ]; then
    mtu_valid="1"
    mtu=$MTU_DEFAULT
else
    if [[ " ${flags[0]} " =~ " -v " ]] || [[ " ${flags[0]} " =~ " --value " ]]; then
        mtu_valid="1"
        mtu=${flags[1]}
    fi
fi

if [ "$mtu_valid" = "1" ]; then

    

    mtu=$(calculate_closest_mtu $mtu $IPV6_HEADER_SIZE $PAYLOAD_MULTIPLES)

    echo "Hola!!!!! MTU is $mtu"


fi


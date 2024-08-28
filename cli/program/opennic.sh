#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/program/opennic --commit $comit_id --device $device_index --project $project_name --remote $remote_option --version $vivado_version
#example: /opt/sgrt/cli/program/opennic --commit   8077751 --device             1 --project   hello_world --remote              0 --version          2022.1

#inputs
commit_name=$2
device_index=$4
project_name=$6
vivado_version=$8
deploy_option=${10}
servers_family_list=${11}

#constants
BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

#get FDEV_NAME
FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)

#set bitstream name
BITSTREAM_NAME=${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit

#get workflow (print echo)
workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)

#revert device (it DOES NOT remove the driver)
if [[ "$workflow" = "vivado" ]]; then
    echo "${bold}$CLI_NAME program revert${normal}"    
    echo ""
fi
$CLI_PATH/program/revert -d $device_index --version $vivado_version
if [[ "$workflow" = "vivado" ]]; then
    echo ""
fi

#get system interfaces (before adding the OpenNIC interface)
before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#get upstream port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#program bitstream 
$CLI_PATH/program/vivado --bitstream $DIR/$BITSTREAM_NAME --device $device_index --version $vivado_version

#get RS_FEC_ENABLED from .device_config
rs_fec=$($CLI_PATH/common/get_config_param $CLI_PATH "$DIR/.device_config" "rs_fec")

#insert driver
eval "$CLI_PATH/program/driver -i $DIR/$DRIVER_NAME -p RS_FEC_ENABLED=$rs_fec"

#get system interfaces (after adding the OpenNIC interface)
after=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#remove the trailing colon if it exists
after=${after%:}

#use comm to find the "extra" OpenNIC
eno_onic=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort))

#get system mask
mellanox_name=$(nmcli dev | grep mellanox-0 | awk '{print $1}')
netmask=$(ifconfig "$mellanox_name" | grep 'netmask' | awk '{print $4}')

#get device mac address
MACs=$($CLI_PATH/get/get_fpga_device_param $device_index MAC)
MAC0="${MACs%%/*}"

#get device ip
IPs=$($CLI_PATH/get/get_fpga_device_param $device_index IP)
IP0="${IPs%%/*}"

#assign to opennic
if [ -n "$eno_onic" ]; then
    echo "${bold}Setting IP address:${normal}"
    echo ""
    echo "sudo $CLI_PATH/program/opennic_ifconfig $eno_onic $MAC0 $IP0 $netmask"
    echo ""
    sudo $CLI_PATH/program/opennic_ifconfig $eno_onic $MAC0 $IP0 $netmask
    echo "$(ifconfig $eno_onic)"
    #check on IP
    current_ip=$(ifconfig $eno_onic | grep 'inet ' | awk '{print $2}')
    if [ "$current_ip" != "$IP0" ]; then
        echo ""
        echo "The OpenNIC interface was not properly setup."
    fi
else
    echo "The OpenNIC interface was not properly setup."
    echo ""
    exit
fi
echo ""

#programming remote servers (if applies)
programming_string="$CLI_PATH/program/opennic --commit $commit_name --device $device_index --project $project_name --version $vivado_version --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$programming_string" "$servers_family_list"

#author: https://github.com/jmoya82
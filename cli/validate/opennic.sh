#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/validate/opennic --commit $commit_name_shell $commit_name_driver --device $device_index --version $vivado_version
#example: /opt/sgrt/cli/validate/opennic --commit            8077751             1cf2578 --device             1 --version          2022.2

#inputs
commit_name_shell=$2
commit_name_driver=$3
device_index=$5
vivado_version=$7

#constants
BIT_NAME="open_nic_shell.bit"
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
DEPLOY_OPTION="0"
FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
NUM_PINGS="5"
WORKFLOW="opennic"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#create directory
mkdir -p "$MY_PROJECTS_PATH/$WORKFLOW"

#cleanup bitstreams folder
if [ -e "$BITSTREAMS_PATH/foo" ]; then
    sudo $CLI_PATH/common/rm "$BITSTREAMS_PATH/foo"
fi

#get device_name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#platform to FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#set project name
project_name="validate_opennic.$commit_name_driver.$FDEV_NAME.$vivado_version"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell/$project_name"
SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
DRIVER_DIR="$DIR/open-nic-driver"

#new
if ! [ -d "$DIR" ]; then
    $CLI_PATH/new/opennic --commit $commit_name_shell,$commit_name_driver --project $project_name --push 0 
fi

#build
library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name_shell/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$DIR/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
if [ -e "$library_shell" ]; then
    cp "$library_shell" "$project_shell"
fi
$CLI_PATH/build/opennic --commit $commit_name_shell --platform $platform --project $DIR --version $vivado_version

#revert device
$CLI_PATH/program/revert -d $device_index --version $vivado_version

#get system interfaces (before adding the OpenNIC interface)
before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#program opennic
$CLI_PATH/program/opennic --commit $commit_name_shell --device $device_index --project $project_name --version $vivado_version --remote $DEPLOY_OPTION

#get system interfaces (after adding the OpenNIC interface)
after=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#remove the trailing colon if it exists
after=${after%:}

#use comm to find the "extra" OpenNIC
eno_onic=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort))

#read FPGA_SERVERS_LIST excluding the current hostname
IFS=$'\n' read -r -d '' -a remote_servers < <(grep -v "^$hostname$" "$FPGA_SERVERS_LIST" && printf '\0')

#get target remote host
if [[ ${#remote_servers[@]} -gt 0 ]]; then
    target_host=${remote_servers[0]}
    #ping
    echo "${bold}ping -I $eno_onic -c $NUM_PINGS $target_host${normal}"
    echo ""
    ping -I $eno_onic -c $NUM_PINGS $target_host
fi

echo ""
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
BIT_NAME="open_nic_shell.bit"
DRIVER_NAME="onic.ko"
BITSTREAMS_PATH="$CLI_PATH/bitstreams" #$($CLI_PATH/common/get_constant $CLI_PATH BITSTREAMS_PATH)
NUM_JOBS="16"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
NUM_PINGS="5"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on virtualized servers
virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
if [ "$virtualized" = "1" ]; then
    #echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check on valid Vivado and Vitis version
#if [ -z "$(echo $XILINX_VIVADO)" ] || [ -z "$(echo $XILINX_VITIS)" ]; then
#    echo ""
#    echo "Please, source a valid Vivado and Vitis version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on valid Vivado and Vitis HLS version
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vitis_version=$($CLI_PATH/common/get_xilinx_version vitis)
if [ -z "$(echo $vivado_version)" ] || [ -z "$(echo $vitis_version)" ] || ([ "$vivado_version" != "$vitis_version" ]); then
    #echo ""
    echo "Please, source valid Vivado and Vitis HLS versions for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check for vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "false" ]; then
    #echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#create directory
mkdir -p "$MY_PROJECTS_PATH/$WORKFLOW"

#inputs
read -a flags <<< "$@"

#initial echo
#echo ""

#check on flags
commit_found_shell=""
commit_name_shell=""
commit_found_driver=""
commit_name_driver=""
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    #commit dialog
    commit_found_shell="1"
    commit_found_driver="1"
    commit_name_shell=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
    commit_name_driver=$(cat $CLI_PATH/constants/ONIC_DRIVER_COMMIT)
    #header (1/2)
    #echo ""
    echo "${bold}sgutil validate $WORKFLOW (commit ID shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
    #device_dialog
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    else
        #echo ""
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        echo ""
        #check on acap (temporal until OpenNIC works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            #echo ""
            echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
            echo ""
            exit
        fi
    fi
else
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')
    # Check if commit_name contains exactly one comma
    if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
        $CLI_PATH/help/validate_opennic $ONIC_SHELL_COMMIT $ONIC_DRIVER_COMMIT
        exit
    fi
    #get shell and driver commits (shell_commit,driver_commit)
    commit_name_shell=${commit_name%%,*}
    commit_name_driver=${commit_name#*,}
    #forbidden combinations
    #if [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ]); then 
    #    
    #    echo "Number 2"
    #
    #    $CLI_PATH/sgutil validate $WORKFLOW -h
    #    exit
    #fi
    #check if commits exist
    exists_shell=$(gh api repos/Xilinx/open-nic-shell/commits/$commit_name_shell 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    exists_driver=$(gh api repos/Xilinx/open-nic-driver/commits/$commit_name_driver 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    if [ "$commit_found" = "0" ]; then 
        commit_name_shell=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
        commit_name_driver=$(cat $CLI_PATH/constants/ONIC_DRIVER_COMMIT)
    elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ]); then 
        $CLI_PATH/help/validate_opennic $ONIC_SHELL_COMMIT $ONIC_DRIVER_COMMIT
        exit
    elif [ "$commit_found" = "1" ] && ([ "$exists_shell" = "0" ] || [ "$exists_driver" = "0" ]); then 
        #echo ""
        echo "Sorry, the commit IDs (shell and driver) ${bold}$commit_name_shell,$commit_name_driver${normal} do not exist on the repository."
        echo ""
        exit
    fi
    #header (2/2) =====> moved to forgotten mandatory 1
    #echo ""
    #echo "${bold}sgutil validate $WORKFLOW (commit ID shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
    #echo ""
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    if ([ "$device_found" = "1" ] && [ -z "$device_index" ]) || 
       ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && [ "$device_index" -ne 1 ]) || 
       ([ "$device_found" = "1" ] && { [ "$device_index" -gt "$MAX_DEVICES" ] || [ "$device_index" -lt 1 ]; }); then
        $CLI_PATH/help/validate_opennic $ONIC_SHELL_COMMIT $ONIC_DRIVER_COMMIT
        exit
    fi
    #check on acap (temporal until OpenNIC works on Versal)
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if ([ "$device_found" = "1" ] && [[ $device_type = "acap" ]]); then
        #echo ""
        echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
        echo ""
        exit
    fi
    #header (2/2)
    #echo ""
    echo "${bold}sgutil validate $WORKFLOW (commit ID shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
    #device_dialog (forgotten mandatory 1)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        #check on acap (temporal until OpenNIC works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            #echo ""
            echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
            echo ""
            exit
        fi
        #echo ""
    fi
fi

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
$CLI_PATH/build/opennic --commit $commit_name_shell --platform $platform --project $DIR

#revert device
$CLI_PATH/program/revert -d $device_index --version $vivado_version

#get system interfaces (before adding the OpenNIC interface)
before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#program opennic
$CLI_PATH/program/opennic --project $DIR --device $device_index --commit $commit_name_shell --remote 0

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
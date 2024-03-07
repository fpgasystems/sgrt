#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"
VIVADO_DEVICES_MAX=$(cat $CLI_PATH/constants/VIVADO_DEVICES_MAX)
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="coyote"
#BIT_NAME="cyt_top.bit"
DRIVER_NAME="coyote_drv.ko"
COYOTE_MAX_REGIONS=16

#combine ACAP and FPGA lists removing duplicates
SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST /$CLI_PATH/constants/FPGA_SERVERS_LIST)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

#check on virtualized servers
virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
if [ "$virtualized" = "1" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA)
acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check on valid Vivado version
#if [ -z "$(echo $XILINX_VIVADO)" ]; then
#    echo ""
#    echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on valid Vivado version
#vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)

#if [ -z "$vivado_version" ]; then #if [ -z "$(echo $vivado_version)" ]; then
#    echo ""
#    echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check for vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "false" ]; then
    echo ""
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

#inputs
read -a flags <<< "$@"

#program regions (only two flags are detected and the first one is --regions)
if [[ ${#flags[@]} -eq 2 && ${flags[0]} = "--regions" ]]; then
    regions_number=${flags[1]}
    if [[ "$regions_number" -gt "$COYOTE_MAX_REGIONS" || "$regions_number" -lt 1 ]]; then
        $CLI_PATH/sgutil program coyote -h
    else
        echo ""
        echo "${bold}Enabling vFPGA regions:${normal}"
        echo ""
        $CLI_PATH/program/enable_regions $regions_number
        echo ""
    fi
    exit
fi

#version_dialog_check
result="$("$CLI_PATH/common/version_dialog_check" "${flags[@]}")"
vivado_version=$(echo "$result" | sed -n '2p')

#check on Vivado version
if [ -n "$vivado_version" ]; then
    #vivado_version is not empty and we check if the Vivado directory exists
    if [ ! -d $VIVADO_PATH/$vivado_version ]; then
        echo ""
        echo "Please, choose a valid Vivado version for ${bold}$hostname!${normal}"
        echo ""
        exit 1
    fi
else
    #vivado_version is empty and we set the more recent Vivado version by default
    vivado_version=$(find "$VIVADO_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -V | tail -n 1)

    #vivado_version and VIVADO_PATH are empty
    if [ -z "$vivado_version" ]; then
        echo ""
        echo "Please, source a valid Vivado version for ${bold}$hostname!${normal}"
        echo ""
        exit 1
    fi
fi

#check if workflow exists
if ! [ -d "$MY_PROJECTS_PATH/$WORKFLOW/" ]; then
    echo ""
    echo "You must build your project first! Please, use sgutil build coyote"
    echo ""
    exit
fi

#check on flags
project_found=""
project_name=""
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    #header (1/2)
    echo ""
    echo "${bold}sgutil program coyote${normal}"
    #project_dialog
    echo ""
    echo "${bold}Please, choose your $WORKFLOW project:${normal}"
    echo ""
    result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW)
    project_found=$(echo "$result" | sed -n '1p')
    project_name=$(echo "$result" | sed -n '2p')
    multiple_projects=$(echo "$result" | sed -n '3p')
    if [[ $multiple_projects = "0" ]]; then
        echo $project_name
    fi
    #device_dialog
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    else
        echo ""
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        #check on VIVADO_DEVICES_MAX
        vivado_devices=$($CLI_PATH/common/get_vivado_devices $CLI_PATH $MAX_DEVICES $device_index)
        if [ $vivado_devices -ge $((VIVADO_DEVICES_MAX)) ]; then
            echo ""
            echo "Sorry, you have reached the maximum number of devices in ${bold}Vivado workflow!${normal}"
            echo ""
            exit
        fi
        #check on acap (temporal until Coyote works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            echo ""
            echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
            echo ""
            exit
        fi
    fi
    #get_servers
    echo ""
    echo "${bold}Quering remote servers with ssh:${normal}"
    result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
    servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
    servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
    num_remote_servers=$(echo "$servers_family_list" | wc -w)
    echo ""
    echo "Done!"
    echo ""
    #deployment_dialog
    deploy_option="0"
    if [ "$num_remote_servers" -ge 1 ]; then
        echo "${bold}Please, choose your deployment servers:${normal}"
        echo ""
        echo "0) $hostname"
        echo "1) $hostname, $servers_family_list_string"
        deploy_option=$($CLI_PATH/common/deployment_dialog $servers_family_list_string)
        echo ""
    fi
else
    #project_dialog_check
    result="$("$CLI_PATH/common/project_dialog_check" "${flags[@]}")"
    project_found=$(echo "$result" | sed -n '1p')
    project_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$project_name" ]); then 
        $CLI_PATH/sgutil program coyote -h
        exit
    fi
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/sgutil program coyote -h
        exit
    fi
    #check on VIVADO_DEVICES_MAX
    if [ "$device_found" = "1" ]; then
        vivado_devices=$($CLI_PATH/common/get_vivado_devices $CLI_PATH $MAX_DEVICES $device_index)
        if [ $vivado_devices -ge $((VIVADO_DEVICES_MAX)) ]; then
            echo ""
            echo "Sorry, you have reached the maximum number of devices in ${bold}Vivado workflow!${normal}"
            echo ""
            exit
        fi
    fi
    #check on acap (temporal until Coyote works on Versal)
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if ([ "$device_found" = "1" ] && [[ $device_type = "acap" ]]); then
        echo ""
        echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
        echo ""
        exit
    fi
    #deployment_dialog_check
    result="$("$CLI_PATH/common/deployment_dialog_check" "${flags[@]}")"
    deploy_option_found=$(echo "$result" | sed -n '1p')
    deploy_option=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$deploy_option_found" = "1" ] && { [ "$deploy_option" -ne 0 ] && [ "$deploy_option" -ne 1 ]; }; then #if [ "$deploy_option_found" = "1" ] && [ -n "$deploy_option" ]; then 
        $CLI_PATH/sgutil program coyote -h
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil program coyote${normal}"
    echo ""
    #project_dialog (forgotten mandatory 1)
    if [[ $project_found = "0" ]]; then
        #echo ""
        echo "${bold}Please, choose your $WORKFLOW project:${normal}"
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW)
        project_found=$(echo "$result" | sed -n '1p')
        project_name=$(echo "$result" | sed -n '2p')
        multiple_projects=$(echo "$result" | sed -n '3p')
        if [[ $multiple_projects = "0" ]]; then
            echo $project_name
        fi
        echo ""
    fi
    #device_dialog (forgotten mandatory 2)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        #check on VIVADO_DEVICES_MAX
        vivado_devices=$($CLI_PATH/common/get_vivado_devices $CLI_PATH $MAX_DEVICES $device_index)
        if [ $vivado_devices -ge $((VIVADO_DEVICES_MAX)) ]; then
            echo ""
            echo "Sorry, you have reached the maximum number of devices in ${bold}Vivado workflow!${normal}"
            echo ""
            exit
        fi
        #check on acap (temporal until Coyote works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            echo ""
            echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
            echo ""
            exit
        fi
        echo ""
    fi
    #deployment_dialog (forgotten mandatory 3)
    #get_servers
    echo "${bold}Quering remote servers with ssh:${normal}"
    result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
    servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
    servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
    num_remote_servers=$(echo "$servers_family_list" | wc -w)
    echo ""
    echo "Done!"
    echo ""
    if [ "$deploy_option_found" = "0" ]; then
        
        #deployment_dialog
        deploy_option="0"
        if [ "$num_remote_servers" -ge 1 ]; then
            echo "${bold}Please, choose your deployment servers:${normal}"
            echo ""
            echo "0) $hostname"
            echo "1) $hostname, $servers_family_list_string"
            deploy_option=$($CLI_PATH/common/deployment_dialog $servers_family_list_string)
            echo ""
        fi
    fi
fi

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name"

#check if project exists
if ! [ -d "$DIR" ]; then
    echo ""
    echo "$DIR is not a valid --project name!"
    echo ""
    exit
fi

#platform to FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#define directories (2)
#APP_BUILD_DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name/build_dir.$FDEV_NAME.$vivado_version/"

#check for build directory
#if ! [ -d "$APP_BUILD_DIR" ]; then
#    echo "You must build your project first! Please, use sgutil build coyote"
#    echo ""
#    exit
#fi

#change directory
#cd $APP_BUILD_DIR

#set bitstream name
BIT_NAME="cyt_top.$FDEV_NAME.$vivado_version.bit"

#check on bitstream
if ! [ -e "$MY_PROJECTS_PATH/$WORKFLOW/$BIT_NAME" ]; then
    echo "You must build your project first! Please, use sgutil build coyote"
    echo ""
    exit
fi

#prgramming local server
echo "Programming ${bold}$hostname...${normal}"

#program bitstream
#$CLI_PATH/program/vivado --device $device_index -b $BIT_NAME --driver $DRIVER_NAME
$CLI_PATH/program/vivado --device $device_index -b $MY_PROJECTS_PATH/$WORKFLOW/$BIT_NAME -v $vivado_version

#get IP address
IP_address_0=$($CLI_PATH/get/network -d $device_index | awk '$1 == "1:" {print $2}')
IP_address_0_hex=$($CLI_PATH/common/address_to_hex IP $IP_address_0)

#get MAC address
MAC_address_0=$($CLI_PATH/get/network -d $device_index | awk '$1 == "1:" {print $3}' | tr -d '()')
MAC_address_0_hex=$($CLI_PATH/common/address_to_hex MAC $MAC_address_0)

#insert coyote driver
#eval "$CLI_PATH/program/driver -m $APP_BUILD_DIR$DRIVER_NAME -p ip_addr_q0=$IP_address_0_hex,mac_addr_q0=$MAC_address_0_hex"
eval "$CLI_PATH/program/driver -m $MY_PROJECTS_PATH/$WORKFLOW/$DRIVER_NAME -p ip_addr_q0=$IP_address_0_hex,mac_addr_q0=$MAC_address_0_hex"


#get N_REGIONS (vFPGAs) from /sys/kernel/coyote_cnfg/cyt_attr_cnfg  ==> /sys/kernel/coyote_sysfs_a1_00
#N_REGIONS=$(cat /sys/kernel/coyote_cnfg/cyt_attr_cnfg | grep vFPGA | awk -F': ' '{print $2}')

#enable vFPGA regions
#$CLI_PATH/program/enable_N_REGIONS $DIR $upstream_port
$CLI_PATH/program/enable_N_REGIONS $device_index

#programm additional region
#ADDITIONAL_REGION="150"
#echo $ADDITIONAL_REGION
#sudo $CLI_PATH/program/fpga_chmod $ADDITIONAL_REGION

#programming remote servers (if applies)
if [ "$deploy_option" -eq 1 ]; then 
    #remote servers
    echo ""
    echo "${bold}Programming remote servers...${normal}"
    echo ""
    #convert string to array
    IFS=" " read -ra servers_family_list_array <<< "$servers_family_list"
    for i in "${servers_family_list_array[@]}"; do
        #remote servers
        #echo ""
        #echo "Programming remote server ${bold}$i...${normal}"
        #echo ""
        #remotely program bitstream, driver, and run enable_regions/enable_N_REGIONS
        #ssh -t $USER@$i "cd $APP_BUILD_DIR ; $CLI_PATH/program/vivado --device $device_index -b $BIT_NAME --driver $DRIVER_NAME -v $vivado_version ; $CLI_PATH/program/enable_N_REGIONS $DIR"
        ssh -t $USER@$i "$CLI_PATH/program/coyote --device $device_index --project $project_name --remote 0"

    done
fi

echo ""
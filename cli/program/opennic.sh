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
WORKFLOW="opennic"
DRIVER_NAME="onic.ko"
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
#IFCONFIG_INTERFACE_BASE_NAME="eno"
#ONIC_INTERFACE_NAME="enonic"

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

#create devices_acap_fpga_coyote
sudo $CLI_PATH/common/get_devices_acap_fpga_coyote

#inputs
read -a flags <<< "$@"

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
    echo "You must build your project first! Please, use sgutil build $WORKFLOW"
    echo ""
    exit
fi

#check on flags
commit_found=""
commit_name=""
project_found=""
project_name=""
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    #check on PWD
    project_path=$(dirname "$PWD")
    commit_name=$(basename "$project_path")
    project_found="0"
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
        commit_found="1"
        project_found="1"
        project_name=$(basename "$PWD")
        #echo ""
        #echo "${bold}Please, choose your $WORKFLOW project:${normal}"
        #echo ""
        #echo $project_name
        #echo ""
    elif [ "$commit_name" = "$WORKFLOW" ]; then
        commit_found="1"
        commit_name="${PWD##*/}"
    else
        commit_found="1"
        commit_name=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
    fi
    #header (1/2)
    echo ""
    echo "${bold}sgutil program $WORKFLOW (commit ID: $commit_name)${normal}"
    #project_dialog
    if [[ $project_found = "0" ]]; then
        echo ""
        echo "${bold}Please, choose your $WORKFLOW project:${normal}"
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
        project_found=$(echo "$result" | sed -n '1p')
        project_name=$(echo "$result" | sed -n '2p')
        multiple_projects=$(echo "$result" | sed -n '3p')
        if [[ $multiple_projects = "0" ]]; then
            echo $project_name
        fi
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
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')
    #check if commit exists
    exists=$(gh api repos/Xilinx/open-nic-shell/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    #forbidden combinations
    if [ "$commit_found" = "0" ]; then 
        commit_found="1"
        commit_name=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
    elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
        $CLI_PATH/sgutil program $WORKFLOW -h
        exit
    elif [ "$commit_found" = "1" ] && [ "$exists" = "0" ]; then 
        echo ""
        echo "Sorry, the commit ID ${bold}$commit_name${normal} does not exist on the repository."
        echo ""
        exit
    fi
    #project_dialog_check
    result="$("$CLI_PATH/common/project_dialog_check" "${flags[@]}")"
    project_found=$(echo "$result" | sed -n '1p')
    project_path=$(echo "$result" | sed -n '2p')
    project_name=$(echo "$result" | sed -n '3p')
    #forbidden combinations
    if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$project_path" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]); then  
        $CLI_PATH/sgutil program $WORKFLOW -h
        exit
    fi
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/sgutil program $WORKFLOW -h
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
        $CLI_PATH/sgutil program $WORKFLOW -h
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil program $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    #check on PWD
    project_path=$(dirname "$PWD")
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
        project_found="1"
        project_name=$(basename "$PWD")
        #echo ""
        #echo "${bold}Please, choose your $WORKFLOW project:${normal}"
        #echo ""
        #echo $project_name
        #echo ""
    fi
    #project_dialog (forgotten mandatory 1)
    if [[ $project_found = "0" ]]; then
        #echo ""
        echo "${bold}Please, choose your $WORKFLOW project:${normal}"
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
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
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

#check if project exists
if ! [ -d "$DIR" ]; then
    echo ""
    echo "$DIR is not a valid project name!"
    echo ""
    exit
fi

#platform to FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#set bitstream name
BIT_NAME="open_nic_shell.$FDEV_NAME.$vivado_version.bit"

#check on bitstream
if ! [ -e "$DIR/$BIT_NAME" ]; then
    echo "You must build your project first! Please, use sgutil build $WORKFLOW"
    echo ""
    exit
fi

#prgramming local server
#echo "Programming ${bold}$hostname...${normal}"
#echo ""

#revert device (it removes driver as well)
eval "$CLI_PATH/program/revert -d $device_index"

#get system interfaces (before adding the OpenNIC interface)
before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#get upstream port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#specific OpenNIC commands (https://github.com/Xilinx/open-nic-shell/blob/main/script/setup_device.sh)
device_bdf="0000:$upstream_port"
bridge_bdf=""
bridge_bdf=$(basename $(dirname $(readlink "/sys/bus/pci/devices/$device_bdf")))
if [ -e "/sys/bus/pci/devices/$device_bdf" ]; then
    echo "${bold}PCIe bridge setup:${normal}"
    echo ""
    # COMMAND register: clear SERR# enable (sudo setpci -s $bridge_bdf COMMAND=0000:0100)
    echo "sudo $CLI_PATH/program/opennic_setpci $bridge_bdf COMMAND=0000:0100"
    sudo $CLI_PATH/program/opennic_setpci $bridge_bdf "COMMAND=0000:0100"
    sleep 1
    # DevCtl register of CAP_EXP: clear ERR_FATAL (Fatal Error Reporting Enable - sudo setpci -s $bridge_bdf CAP_EXP+8.w=0000:0004)
    echo "sudo $CLI_PATH/program/opennic_setpci $bridge_bdf CAP_EXP+8.w=0000:0004"
    sudo $CLI_PATH/program/opennic_setpci $bridge_bdf "CAP_EXP+8.w=0000:0004"
    sleep 1
    echo ""
fi

#program bitstream 
$CLI_PATH/program/vivado --device $device_index -b $DIR/$BIT_NAME -v $vivado_version

#enable memory space access
echo "${bold}PCIe device setup:${normal}"
echo ""
echo "sudo $CLI_PATH/program/opennic_setpci $device_bdf COMMAND=0x02"
sudo $CLI_PATH/program/opennic_setpci $device_bdf "COMMAND=0x02"
sleep 1

#insert driver
eval "$CLI_PATH/program/driver -m $DIR/$DRIVER_NAME -p RS_FEC_ENABLED=0"

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
fi
echo ""

#programming remote servers (if applies)
#if [ "$deploy_option" -eq 1 ]; then 
#    #remote servers
#    echo ""
#    echo "${bold}Programming remote servers...${normal}"
#    echo ""
#    #convert string to array
#    IFS=" " read -ra servers_family_list_array <<< "$servers_family_list"
#    for i in "${servers_family_list_array[@]}"; do
#        #remote servers
#        #echo ""
#        #echo "Programming remote server ${bold}$i...${normal}"
#        #echo ""
#        #remotely program bitstream, driver, and run enable_regions/enable_N_REGIONS
#        #ssh -t $USER@$i "cd $APP_BUILD_DIR ; $CLI_PATH/program/vivado --device $device_index -b $BIT_NAME --driver $DRIVER_NAME -v $vivado_version ; $CLI_PATH/program/enable_N_REGIONS $DIR"
#        ssh -t $USER@$i "$CLI_PATH/program/$WORKFLOW --device $device_index --project $project_name --remote 0"
#
#    done
#fi

#echo ""
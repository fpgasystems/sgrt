#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/program/opennic --commit $comit_id --device $device_index --project $project_name --remote $remote_option --version $vivado_version
#example: /opt/sgrt/cli/program/opennic --commit   8077751 --device             1 --project   hello_world --remote              0

#inputs
commit_name=$2
device_index=$4
project_name=$6
deploy_option=$8
vivado_version=${10}

echo "Inside"

echo $commit_name
echo $device_index
echo $project_name
echo $deploy_option
echo $vivado_version

#constants
DRIVER_NAME="onic.ko"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#combine ACAP and FPGA lists removing duplicates
#SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST /$CLI_PATH/constants/FPGA_SERVERS_LIST)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get username
username=$USER

#inputs
read -a flags <<< "$@"

#check if workflow exists
if ! [ -d "$MY_PROJECTS_PATH/$WORKFLOW/" ]; then

    echo "I am here (1)"

    echo ""
    echo "You must build your project first! Please, use sgutil build $WORKFLOW"
    echo ""
    exit
fi

#if [ "$flags" = "" ]; then
#    #get_servers
#    echo ""
#    echo "${bold}Quering remote servers with ssh:${normal}"
#    result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
#    servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
#    servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
#    num_remote_servers=$(echo "$servers_family_list" | wc -w)
#    echo ""
#    echo "Done!"
#    #echo ""
#    #deployment_dialog
#    deploy_option="0"
#    if [ "$num_remote_servers" -ge 1 ]; then
#        echo "${bold}Please, choose your deployment servers:${normal}"
#        echo ""
#        echo "0) $hostname"
#        echo "1) $hostname, $servers_family_list_string"
#        deploy_option=$($CLI_PATH/common/deployment_dialog $servers_family_list_string)
#        echo ""
#    fi
#else
#    #deployment_dialog_check
#    result="$("$CLI_PATH/common/deployment_dialog_check" "${flags[@]}")"
#    deploy_option_found=$(echo "$result" | sed -n '1p')
#    deploy_option=$(echo "$result" | sed -n '2p')
#    #forbidden combinations
#    if [ "$deploy_option_found" = "1" ] && { [ "$deploy_option" -ne 0 ] && [ "$deploy_option" -ne 1 ]; }; then #if [ "$deploy_option_found" = "1" ] && [ -n "$deploy_option" ]; then 
#        $CLI_PATH/sgutil program $WORKFLOW -h
#        exit
#    fi
#    #deployment_dialog (forgotten mandatory 3)
#    #get_servers
#    echo "${bold}Quering remote servers with ssh:${normal}"
#    result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
#    servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
#    servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
#    num_remote_servers=$(echo "$servers_family_list" | wc -w)
#    echo ""
#    echo "Done!"
#    #echo ""
#    if [ "$deploy_option_found" = "0" ]; then
#        #deployment_dialog
#        deploy_option="0"
#        if [ "$num_remote_servers" -ge 1 ]; then
#            echo "${bold}Please, choose your deployment servers:${normal}"
#            echo ""
#            echo "0) $hostname"
#            echo "1) $hostname, $servers_family_list_string"
#            deploy_option=$($CLI_PATH/common/deployment_dialog $servers_family_list_string)
#            echo ""
#        fi
#    fi
#fi

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

echo "$DIR/$BIT_NAME"

#check on bitstream
if ! [ -e "$DIR/$BIT_NAME" ]; then

    echo "I am here (2)"

    echo ""
    echo "You must build your project first! Please, use sgutil build $WORKFLOW"
    echo ""
    exit
fi

#prgramming local server
#echo "Programming ${bold}$hostname...${normal}"
#echo ""

#get workflow (print echo)
workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)

#revert device (it removes driver as well)
if [[ $workflow = "vivado" ]]; then
    echo ""
fi
$CLI_PATH/program/revert -d $device_index --version $vivado_version

#get system interfaces (before adding the OpenNIC interface)
before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#get upstream port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#program bitstream 
if [[ $workflow = "vitis" ]]; then
    echo ""
fi
$CLI_PATH/program/vivado --device $device_index -b $DIR/$BIT_NAME -v $vivado_version

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

#author: https://github.com/jmoya82
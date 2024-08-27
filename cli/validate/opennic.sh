#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/validate/opennic --commit $commit_name_shell $commit_name_driver --device $device_index --RS_FEC_ENABLED $rs_fec --version $vivado_version
#example: /opt/sgrt/cli/validate/opennic --commit            8077751             1cf2578 --device             1 --RS_FEC_ENABLED 1       --version          2022.2

check_connectivity() {
    local interface="$1"
    local remote_server="$2"

    # Ping the remote server using the specified interface, sending only 1 packet
    if ping -I "$interface" -c 1 "$remote_server" &> /dev/null; then
        echo "1"
    else
        echo "0"
    fi
}

#inputs
commit_name_shell=$2
commit_name_driver=$3
device_index=$5
rs_fec=$7
vivado_version=$9

#constants
BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
DEPLOY_OPTION="0"
DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
NUM_PINGS="5"
WORKFLOW="opennic"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#cleanup bitstreams folder
if [ -e "$BITSTREAMS_PATH/foo" ]; then
    sudo $CLI_PATH/common/rm "$BITSTREAMS_PATH/foo"
fi

#get device_name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#get platform_name
platform_name=$($CLI_PATH/get/get_fpga_device_param $device_index platform)

#get FDEV_NAME
FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)

#set project name
project_name="validate_opennic.$commit_name_driver.$FDEV_NAME.$vivado_version"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell/$project_name"
SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
DRIVER_DIR="$DIR/open-nic-driver"

#new
if ! [ -d "$DIR" ]; then
    echo "${bold}$CLI_NAME new $WORKFLOW (commit IDs for shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
    $CLI_PATH/new/opennic --commit $commit_name_shell $commit_name_driver --project $project_name --push 0 
fi

#cleanup
rm -f $DIR/configs/host_config_000

#create default configurations
#if [ ! -f "$DIR/configs/device_config" ]; then
    #device
    touch $DIR/configs/device_config
    echo "min_pkt_len = 64;" >> "$DIR/configs/device_config"
    echo "max_pkt_len = 1514;" >> "$DIR/configs/device_config"
    echo "use_phys_func = 1;" >> "$DIR/configs/device_config"
    echo "num_phys_func = 1;" >> "$DIR/configs/device_config"
    echo "num_qdma = 1;" >> "$DIR/configs/device_config"
    echo "num_queue = 512;" >> "$DIR/configs/device_config"
    echo "num_cmac_port = 1;" >> "$DIR/configs/device_config"
    echo "rs_fec = $rs_fec;" >> "$DIR/configs/device_config"
    chmod a-w "$DIR/configs/device_config"

    #host
    touch $DIR/configs/host_config_001
    echo "MAX_NUM_PINGS = 10;" >> "$DIR/configs/host_config_001"
    echo "NUM_PINGS = 5;" >> "$DIR/configs/host_config_001"
    chmod a-w "$DIR/configs/host_config_001"

    #save .device_config
    cp $DIR/configs/device_config $DIR/.device_config
    #chmod a-w "$DIR/.device_config"
#fi

#build
library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name_shell/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
if [ -e "$library_shell" ]; then
    cp "$library_shell" "$project_shell"
fi
echo "${bold}$CLI_NAME build $WORKFLOW (commit ID for shell: $commit_name_shell)${normal}"
echo ""
$CLI_PATH/build/opennic --commit $commit_name_shell $commit_name_driver --config "host_config_001" --platform $platform_name --project $project_name --version $vivado_version
echo ""

#add additional echo (1/2)
workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)

#revert device
if [[ "$workflow" = "vivado" ]]; then
    echo "${bold}$CLI_NAME program revert${normal}"    
    echo ""
fi
$CLI_PATH/program/revert -d $device_index --version $vivado_version

#add additional echo (2/2)
if [[ $workflow = "vivado" ]]; then
    echo ""
fi

#get system interfaces (before adding the OpenNIC interface)
before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#remove driver if exists
if lsmod | grep -q "${DRIVER_NAME%.ko}"; then
    echo "${bold}Removing drivers:${normal}"
    echo ""
    echo "sudo rmmod ${DRIVER_NAME%.ko}"
    sudo rmmod ${DRIVER_NAME%.ko}
    echo ""
fi

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

#set target host
target_host=${remote_servers[0]}

#get connection status
connected=$(check_connectivity "$eno_onic" "$target_host")

#get target remote host
if [[ $connected = "1" ]]; then
    #ping
    if [[ ${#remote_servers[@]} -gt 0 ]]; then
        echo "${bold}ping -I $eno_onic -c $NUM_PINGS $target_host${normal}"
        echo ""
        ping -I $eno_onic -c $NUM_PINGS $target_host
    fi

    #get RS_FEC_ENABLED from .device_config
    rs_fec=$($CLI_PATH/common/get_config_param $CLI_PATH "$DIR/.device_config" "rs_fec")

    #print
    echo ""
    #echo -e "\e[32mOpenNIC validated on ${bold}$hostname (device $device_index)${normal} with ${bold}RS_FEC_ENABLED=$rs_fec!${normal}\e[0m"
    echo -e "\e[32mOpenNIC validated on ${bold}$hostname (device $device_index)${normal}\e[32m with ${bold}RS_FEC_ENABLED=$rs_fec!${normal}\e[0m"
    echo ""
else
    #get RS_FEC_ENABLED from .device_config
    #rs_fec=$($CLI_PATH/common/get_config_param $CLI_PATH "$DIR/.device_config" "rs_fec")

    #switch value
    #if [[ $rs_fec = "0" ]]; then
    #    rs_fec="1"
    #elif [[ $rs_fec = "1" ]]; then
    #    rs_fec="0"
    #fi
    
    #change to switched value
    #chmod a+w "$DIR/configs/device_config"
    #sed -i "s/^rs_fec = .*/rs_fec = $rs_fec/" "$DIR/configs/device_config"
    #chmod a-w "$DIR/configs/device_config"
    #cp -f $DIR/configs/device_config $DIR/.device_config

    #revert and program
    #$CLI_PATH/program/revert -d $device_index --version $vivado_version
    #echo ""
    #before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')
    #$CLI_PATH/program/opennic --commit $commit_name_shell --device $device_index --project $project_name --version $vivado_version --remote $DEPLOY_OPTION
    #after=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')
    #after=${after%:}
    #eno_onic=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort))

    #ping
    #if [[ ${#remote_servers[@]} -gt 0 ]]; then
    #    echo "${bold}ping -I $eno_onic -c $NUM_PINGS $target_host${normal}"
    #    echo ""
    #    ping -I $eno_onic -c $NUM_PINGS $target_host
    #fi

    #print
    #echo ""
    #echo "OpenNIC validated on ${bold}$hostname (device $device_index)${normal} with ${bold}RS_FEC_ENABLED=$rs_fec!${normal}"
    echo -e "\e[31mOpenNIC failed on ${bold}$hostname (device $device_index)${normal}\e[31m with ${bold}RS_FEC_ENABLED=$rs_fec!${normal}\e[0m"
    echo ""
fi

#cleaning
#echo "${bold}Cleaning validation files:${normal}"
##echo ""

#remove driver
##driver_name="${DRIVER_NAME%.ko}"
#sudo rmmod ${DRIVER_NAME%.ko}
#sudo $CLI_PATH/common/rm "$MY_DRIVERS_PATH/$DRIVER_NAME"

#revert
#$CLI_PATH/program/revert -d $device_index --version $vivado_version > /dev/null 2>&1

#remove validation project
rm -rf $DIR

#echo "Done!"
echo ""

#author: https://github.com/jmoya82
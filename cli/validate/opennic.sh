#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
VIVADO_DEVICES_MAX=$(cat $CLI_PATH/constants/VIVADO_DEVICES_MAX)
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
    echo ""
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
    echo ""
    echo "Please, source valid Vivado and Vitis HLS versions for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

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

#create directory
mkdir -p "$MY_PROJECTS_PATH/$WORKFLOW"

#inputs
read -a flags <<< "$@"

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
    echo ""
    echo "${bold}sgutil validate $WORKFLOW (commit ID shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
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
        #check on acap (temporal until OpenNIC works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            echo ""
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
        $CLI_PATH/sgutil validate $WORKFLOW -h
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
    #forbidden combinations
    if [ "$commit_found" = "0" ]; then 
        commit_name_shell=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
        commit_name_driver=$(cat $CLI_PATH/constants/ONIC_DRIVER_COMMIT)
    elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ]); then 
        $CLI_PATH/sgutil validate $WORKFLOW -h
        exit
    elif [ "$commit_found" = "1" ] && ([ "$exists_shell" = "0" ] || [ "$exists_driver" = "0" ]); then 
        echo ""
        echo "Sorry, the commit IDs (shell and driver) ${bold}$commit_name_shell,$commit_name_driver${normal} do not exist on the repository."
        echo ""
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil validate $WORKFLOW (commit ID shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/sgutil validate $WORKFLOW -h
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
    #check on acap (temporal until OpenNIC works on Versal)
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if ([ "$device_found" = "1" ] && [[ $device_type = "acap" ]]); then
        echo ""
        echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
        echo ""
        exit
    fi
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
        #check on VIVADO_DEVICES_MAX
        vivado_devices=$($CLI_PATH/common/get_vivado_devices $CLI_PATH $MAX_DEVICES $device_index)
        if [ $vivado_devices -ge $((VIVADO_DEVICES_MAX)) ]; then
            echo ""
            echo "Sorry, you have reached the maximum number of devices in ${bold}Vivado workflow!${normal}"
            echo ""
            exit
        fi
        #check on acap (temporal until OpenNIC works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            echo ""
            echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
            echo ""
            exit
        fi
        echo ""
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
project_name="validate_opennic.$FDEV_NAME.$vivado_version"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell/$project_name"
SHELL_BUILD_DIR="$DIR/script"
DRIVER_DIR="$DIR/open-nic-driver"

#check on project folder
if ! [ -d "$DIR" ]; then
    #create project folder
    mkdir -p $DIR

    #clone repository
    $CLI_PATH/common/git_clone_opennic $DIR $commit_name_shell $commit_name_driver

    #change to project directory
    cd $DIR

    #save commit_name_shell
    echo "$commit_name_shell" > ONIC_SHELL_COMMIT
    echo "$commit_name_driver" > ONIC_DRIVER_COMMIT

    #define shells
    library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name_shell/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
    #commit_shell="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
    project_shell="$DIR/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

    #compile shell
    if [ -e "$library_shell" ]; then
        cp "$library_shell" "$project_shell"
    elif ! [ -e "$project_shell" ]; then
        #echo ""
        echo "${bold}OpenNIC shell compilation (commit ID: $commit_name_shell):${normal}"
        echo ""
        echo "vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1"
        echo ""
        cd $SHELL_BUILD_DIR
        vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1

        #copy and send email
        if [ -f "$DIR/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BIT_NAME" ]; then
            #copy to project
            cp "$DIR/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BIT_NAME" "$project_shell"
            #send email
            #user_email=$USER@ethz.ch
            #echo "Subject: Good news! sgutil build opennic ($project_name / -DFDEV_NAME=$FDEV_NAME) is done!" | sendmail $user_email
        fi
    fi
fi

#compile driver
#echo ""
echo "${bold}Driver compilation:${normal}"
echo ""
echo "cd $DRIVER_DIR && make"
echo ""
cd $DRIVER_DIR && make

#copy driver
cp -f $DRIVER_DIR/$DRIVER_NAME $DIR/$DRIVER_NAME

#remove drivier files (generated while compilation)
rm $DRIVER_DIR/Module.symvers
rm -rf $DRIVER_DIR/hwmon
rm $DRIVER_DIR/modules.order
rm $DRIVER_DIR/onic.ko 
rm $DRIVER_DIR/onic.mod
rm $DRIVER_DIR/onic.mod.c
rm $DRIVER_DIR/onic.mod.o
rm $DRIVER_DIR/onic.o
rm $DRIVER_DIR/onic_common.o
rm $DRIVER_DIR/onic_ethtool.o
rm $DRIVER_DIR/onic_hardware.o
rm $DRIVER_DIR/onic_lib.o
rm $DRIVER_DIR/onic_main.o
rm $DRIVER_DIR/onic_netdev.o
rm $DRIVER_DIR/onic_sysfs.o

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
    echo ""
    echo "ping -I $eno_onic -c $NUM_PINGS $target_host"
    ping -I $eno_onic -c $NUM_PINGS $target_host
fi

#echo "sudo arping -I $eno_onic $hostname-mellanox-0"
#sudo arping -I $eno_onic $hostname-mellanox-0

echo ""
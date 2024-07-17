#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="coyote"
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)

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
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)

if [ -z "$vivado_version" ]; then #if [ -z "$(echo $vivado_version)" ]; then
    echo ""
    echo "Please, source valid Vivado version for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check for vivado_developers
#member=$($CLI_PATH/common/is_member $USER vivado_developers)
#if [ "$member" = "false" ]; then
#    echo ""
#    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
#    echo ""
#    exit
#fi

#check if workflow exists
if ! [ -d "$MY_PROJECTS_PATH/$WORKFLOW/" ]; then
    echo ""
    echo "You must build and program your project/device first! Please, use sgutil build/program coyote"
    echo ""
    exit
fi

#check on DEVICES_LIST
#source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
#MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

#check on multiple devices
#multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#inputs
read -a flags <<< "$@"

#check on flags
commit_found=""
commit_name=""
project_found=""
project_name=""
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    #commit dialog
    #commit_found="1"
    #commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    #header (1/2)
    #echo ""
    #echo "${bold}sgutil run coyote (commit ID: $commit_name)${normal}"
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
        commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    fi
    #header (1/2)
    echo ""
    echo "${bold}sgutil run coyote (commit ID: $commit_name)${normal}"
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
        #check on acap (temporal until Coyote works on Versal)
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
    #forbidden combinations
    if [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
        $CLI_PATH/sgutil new $WORKFLOW -h
        exit
    fi
    #check if commit exists
    exists=$(gh api repos/fpgasystems/Coyote/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    #forbidden combinations
    if [ "$commit_found" = "0" ]; then 
        commit_found="1"
        commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
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
        $CLI_PATH/sgutil run coyote -h
        exit
    fi
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/sgutil run coyote -h
        exit
    fi
    #check on acap (temporal until Coyote works on Versal)
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if ([ "$device_found" = "1" ] && [[ $device_type = "acap" ]]); then
        echo ""
        echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
        echo ""
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil run coyote (commit ID: $commit_name)${normal}"
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
        #echo ""
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
fi

config_hw="static"
config_sw="perf_local"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

#check if project exists
if ! [ -d "$DIR" ]; then
    echo ""
    echo "$DIR is not a valid --project name!"
    echo ""
    exit
fi

#device_name to coyote string 
#FDEV_NAME=$(echo $HOSTNAME | grep -oP '(?<=-).*?(?=-)')
#if [ "$FDEV_NAME" = "u50d" ]; then
#    FDEV_NAME="u50"
#fi
#device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#get FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#define directories (2)
#APP_BUILD_DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name/build_dir.$FDEV_NAME.$vivado_version/" #$FDEV_NAME
APP_BUILD_DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name/build_dir.$config_sw" #$FDEV_NAME

#check for build directory
if ! [ -d "$APP_BUILD_DIR" ]; then
    echo ""
    echo "You must build your project first! Please, use sgutil build coyote" # before generate (build) / application (project)
    echo ""
    exit
fi

#change directory
echo ""
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $APP_BUILD_DIR"
echo ""
cd $APP_BUILD_DIR

#display configuration
#cd $DIR/configs/
#config_id=$(ls *.active)
#config_id="${config_id%%.*}"

echo "${bold}You are running $config_sw:${normal}"
echo ""
#cat $DIR/configs/config_000.hpp
cat $DIR/configs/config_$config_sw
echo ""
    
#run application
echo "${bold}Running perf_local host (./main -t 1 -d $device_index):${normal}"
./main -t 1 -d $device_index #-b $bus -s $device

echo ""
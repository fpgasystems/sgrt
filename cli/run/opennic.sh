#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/run/opennic --commit $commit_name --device $device_index --project $project_name
#example: /opt/sgrt/cli/run/opennic --commit      8077751 --device             1 --project   hello_world

#inputs
commit_name=$2
device_index=$4
project_name=$6

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

#get FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#define directories (2)
BUILD_DIR="$DIR/build_dir.$FDEV_NAME" 

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $BUILD_DIR"
echo ""
cd $BUILD_DIR

#display configuration
#cd $DIR/configs/
#config_id=$(ls *.active)
#config_id="${config_id%%.*}"

config_sw="config_xxx"

echo "${bold}You are running $config_sw:${normal}"
echo ""
#cat $DIR/configs/config_$config_sw
#echo ""
    
#run application
echo "Your application should run here!"
#echo "${bold}Running perf_local host (./main -t 1 -d $device_index):${normal}"
#./main -t 1 -d $device_index #-b $bus -s $device

echo ""

#author: https://github.com/jmoya82
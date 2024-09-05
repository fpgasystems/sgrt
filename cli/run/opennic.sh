#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/run/opennic --commit $commit_name --config $config_index --device $device_index --project $project_name
#example: /opt/sgrt/cli/run/opennic --commit      8077751 --config             1 --device             1 --project   hello_world

#inputs
commit_name=$2
config_index=$4
device_index=$6
project_name=$8

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

#get FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#define directories (2)
#BUILD_DIR="$DIR/build_dir.$FDEV_NAME" 

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#display configuration
#cd $DIR/configs/
#config_id=$(ls *.active)
#config_id="${config_id%%.*}"

echo "${bold}Device parameters:${normal}"
echo ""
cat $DIR/.device_config
echo ""

#get config name
config_string=$($CLI_PATH/common/get_config_string $config_index)
config_name="host_config_$config_string"

echo "${bold}You are running $config_name:${normal}"
echo ""
cat $DIR/configs/$config_name
echo ""

echo "${bold}Running your OpenNIC application:${normal}"
echo ""
echo "./onic --device $device_index --host alveo-u250-01 --config $config_index"
echo ""
./onic --device "$device_index" --host alveo-u250-01 --config $config_index

#run application
#echo "Your application should run here!"
#echo "${bold}Running perf_local host (./main -t 1 -d $device_index):${normal}"
#./main -t 1 -d $device_index #-b $bus -s $device

echo ""

#author: https://github.com/jmoya82
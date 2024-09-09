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

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#display configuration
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

#run application
echo "${bold}Running your OpenNIC application:${normal}"
echo ""
echo "./onic --config $config_index --device $device_index "
echo ""
./onic --config $config_index --device "$device_index"

echo ""

#author: https://github.com/jmoya82
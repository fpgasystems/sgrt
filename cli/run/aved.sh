#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil run aved --config $config_index --config --device $device_index --project $project_name --tag                            $tag_name
#example: /opt/sgrt/cli/sgutil run aved --config             1 --config --device             1 --project   hello_world --tag amd_v80_gen5x8_23.2_exdes_2_20240408

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#temporal exit condition
echo ""
echo "Sorry, we are working on this!"
echo ""
exit

#inputs
config_index=$2
device_index=$4
project_name=$6
tag_name=$8

#all inputs must be provided
if [ "$config_index" = "" ] || [ "$device_index" = "" ] || [ "$project_name" = "" ] || [ "$tag_name" = "" ]; then
    exit
fi

#I will need to continue here...

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="aved"

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
./onic --config "$config_index" --device "$device_index"
return_code=$?

echo ""

#exit with return code
exit $return_code

#author: https://github.com/jmoya82
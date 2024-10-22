#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program image --device $device_index --partition $partition_index --path          $image_path --remote $deploy_option 
#example: /opt/sgrt/cli/sgutil program image --device             1 --partition                0 --path path_to_my_image.pdi --remote              0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
    exit
fi

#inputs
device_index=$2
partition_index=$4
image_path=$6
deploy_option=$8
servers_family_list=$9

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$partition_index" = "" ] || [ "$image_path" = "" ] || [ "$deploy_option" = "" ]; then
    exit
fi

#check on remote aboslute path
if [ "$deploy_option" = "1" ] && [[ "$image_path" == "./"* ]]; then
    exit
fi

#constants
AVED_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TOOLS_PATH)
BOOT_DEVICE_TYPE="primary"

#derived
AMI_TOOL_PATH="$AVED_TOOLS_PATH/ami_tool"

echo "${bold}sgutil program image${normal}"
echo ""

#extend relative path
current_directory=$(pwd)
if [[ "$image_path" == "./"* ]]; then
    image_path="${current_directory}/${image_path#./}"
fi

#get path and file
path="${image_path%/*}/"
file="${image_path##*/}"

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $path"
echo ""
cd $path

#get upstream_port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#call ami_tool
echo "${bold}Calling AVED Management Interface Tool:${normal}"
echo ""
echo "sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $BOOT_DEVICE_TYPE -i ./$file -p $partition_index -y"
echo ""
sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $BOOT_DEVICE_TYPE -i ./$file -p $partition_index -y
echo ""

#programming remote servers (if applies)
programming_string="$CLI_PATH/program/image --device $device_index --partition $partition_index --path $file_path --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$programming_string" "$servers_family_list"

#author: https://github.com/jmoya82
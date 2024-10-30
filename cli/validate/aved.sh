#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil validate aved --device $device_index
#example: /opt/sgrt/cli/sgutil validate aved --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$vivado_enabled_asoc" = "0" ]; then
    exit
fi

#inputs
device_index=$2

#constants
AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
AVED_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TOOLS_PATH)
AVED_UUID=$($CLI_PATH/common/get_constant $CLI_PATH AVED_UUID)

#all inputs must be provided
if [ "$device_index" = "" ]; then
    exit
fi

#get AVED example design name (amd_v80_gen5x8_23.2_exdes_2)
aved_name=$(echo "$AVED_TAG" | sed 's/_[^_]*$//')

#get device_name
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#get product_name
product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)

#get uuid
current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')

#AVED programming
if [ "$current_uuid" != "$AVED_UUID" ]; then
    echo ""
    echo "${bold}Programming pre-built AVED:${normal}"
    echo ""
    #reprogramming happens with -y
    echo "cd $AVED_PATH/${aved_name}_xbtest_stress"
    echo "sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d c4:00.0 -t primary -i ./design.pdi -p 0 -y"
    echo ""
    cd $AVED_PATH/${aved_name}_xbtest_stress
    sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t primary -i ./design.pdi -p 0 -y
else
    echo ""
    echo "cd $AVED_PATH/${aved_name}_xbtest_stress"
    cd $AVED_PATH/${aved_name}_xbtest_stress
#    #reprogramming can happen if the user wants to (this can be useful when validation fails -- it happens with amd_v80_gen5x8_23.2_exdes_2_20240408) =========> here we need our own dialog... Hey pre-built AVED is already there... Do you want to reprogram????
#    echo "The pre-built AVED is already programmed on the device. Do you want to program it again (y/n)?"
#    while true; do
#        read -p "" yn
#        case $yn in
#            "y")
#                echo ""
#                echo "cd $AVED_PATH/${aved_name}_xbtest_stress"
#                echo "sudo ami_tool cfgmem_program -d c4:00.0 -t primary -i ./design.pdi -p 0 -y"
#                echo ""
#                cd $AVED_PATH/${aved_name}_xbtest_stress
#                sudo ami_tool cfgmem_program -d $upstream_port -t primary -i ./design.pdi -p 0 -y          
#                break
#                ;;
#            "n")
#                echo ""
#                echo "cd $AVED_PATH/${aved_name}_xbtest_stress"
#                cd $AVED_PATH/${aved_name}_xbtest_stress
#                break
#                ;;
#        esac
#    done
fi

#ami_tool validation
ami_tool overview
ami_tool mfg_info -d $upstream_port

#xbtest validation
sudo xbtest -d $upstream_port -c verify
sudo xbtest -d $upstream_port -c memory

echo ""

#author: https://github.com/jmoya82
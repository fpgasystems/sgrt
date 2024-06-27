#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/validate/opennic --commit $commit_name_shell $commit_name_driver --platform                      $platform_name --project $project_name --version $vivado_version
#example: /opt/sgrt/cli/validate/opennic --commit            8077751             1cf2578 --platform xilinx_u55c_gen3x16_xdma_3_202210_1 --project       hello_1 --version          2022.2

#inputs
commit_name=$2
commit_name_driver=$3
platform_name=$5
project_name=$7
vivado_version=$9

#constants

XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
BIT_NAME="open_nic_shell.bit"
DRIVER_NAME="onic.ko"
BITSTREAMS_PATH="$CLI_PATH/bitstreams" #$($CLI_PATH/common/get_constant $CLI_PATH BITSTREAMS_PATH)
NUM_JOBS="16"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on virtualized servers
virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
if [ "$virtualized" = "1" ]; then
    #echo ""
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
#vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
#vitis_version=$($CLI_PATH/common/get_xilinx_version vitis)
#if [ -z "$(echo $vivado_version)" ] || [ -z "$(echo $vitis_version)" ] || ([ "$vivado_version" != "$vitis_version" ]); then
#    #echo ""
#    echo "Please, source valid Vivado and Vitis HLS versions for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check for vivado_developers
#member=$($CLI_PATH/common/is_member $USER vivado_developers)
#if [ "$member" = "false" ]; then
#    #echo ""
#    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
#    echo ""
#    exit
#fi

#check if workflow exists
if ! [ -d "$MY_PROJECTS_PATH/$WORKFLOW/" ]; then
    #echo ""
    echo "You must create your project first! Please, use sgutil new $WORKFLOW"
    echo ""
    exit
fi

#inputs
#read -a flags <<< "$@"

#check on flags
#commit_found=""
#commit_name=""
#project_found=""
#project_name=""
#platform_found=""
#platform_name=""
#if [ "$flags" = "" ]; then
#    #check on PWD
#    project_path=$(dirname "$PWD")
#    commit_name=$(basename "$project_path")
#    project_found="0"
#    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
#        commit_found="1"
#        project_found="1"
#        project_name=$(basename "$PWD")
#        #echo ""
#        #echo "${bold}Please, choose your $WORKFLOW project:${normal}"
#        #echo ""
#        #echo $project_name
#        #echo ""
#    elif [ "$commit_name" = "$WORKFLOW" ]; then
#        commit_found="1"
#        commit_name="${PWD##*/}"
#    else
#        commit_found="1"
#        commit_name=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
#    fi
#    #header (1/2)
#    #echo ""
#    echo "${bold}sgutil build $WORKFLOW (commit ID: $commit_name)${normal}"
#    #project_dialog
#    if [[ $project_found = "0" ]]; then
#        echo ""
#        echo "${bold}Please, choose your $WORKFLOW project:${normal}"
#        echo ""
#        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
#        project_found=$(echo "$result" | sed -n '1p')
#        project_name=$(echo "$result" | sed -n '2p')
#        multiple_projects=$(echo "$result" | sed -n '3p')
#        if [[ $multiple_projects = "0" ]]; then
#            echo $project_name
#        fi
#    fi
#    echo ""
#    #platform_dialog
#    echo "${bold}Please, choose your platform:${normal}"
#    echo ""
#    result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
#    platform_found=$(echo "$result" | sed -n '1p')
#    platform_name=$(echo "$result" | sed -n '2p')
#    multiple_platforms=$(echo "$result" | sed -n '3p')
#    if [[ $multiple_platforms = "0" ]]; then
#        echo $platform_name
#    fi
#    echo ""
#else
#    #commit_dialog_check
#    result="$("$CLI_PATH/common/commit_dialog_check" "${flags[@]}")"
#    commit_found=$(echo "$result" | sed -n '1p')
#    commit_name=$(echo "$result" | sed -n '2p')
#    #forbidden combinations
#    if [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
#        $CLI_PATH/help/build_opennic $CLI_PATH
#        exit
#    fi
#    #check if commit exists
#    exists=$(gh api repos/Xilinx/open-nic-shell/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
#    #forbidden combinations
#    if [ "$commit_found" = "0" ]; then 
#        commit_found="1"
#        commit_name=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
#    elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
#        $CLI_PATH/help/build_opennic $CLI_PATH
#        exit
#    elif [ "$commit_found" = "1" ] && [ "$exists" = "0" ]; then 
#        #echo ""
#        echo "Sorry, the commit ID ${bold}$commit_name${normal} does not exist on the repository."
#        echo ""
#        exit
#    fi
#    #project_dialog_check
#    result="$("$CLI_PATH/common/project_dialog_check" "${flags[@]}")"
#    project_found=$(echo "$result" | sed -n '1p')
#    project_path=$(echo "$result" | sed -n '2p')
#    project_name=$(echo "$result" | sed -n '3p')
#
#    #forbidden combinations
#    if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$project_path" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]); then 
#        $CLI_PATH/help/build_opennic $CLI_PATH
#        exit
#    fi
#    #platform_dialog_check
#    result="$("$CLI_PATH/common/platform_dialog_check" "${flags[@]}")"
#    platform_found=$(echo "$result" | sed -n '1p')
#    platform_name=$(echo "$result" | sed -n '2p')    
#    #forbidden combinations
#    if ([ "$platform_found" = "1" ] && [ "$platform_name" = "" ]) || ([ "$platform_found" = "1" ] && [ ! -d "$XILINX_PLATFORMS_PATH/$platform_name" ]); then
#        $CLI_PATH/help/build_opennic $CLI_PATH
#        exit
#    fi
#    #header (2/2)
#    #echo ""
#    echo "${bold}sgutil build $WORKFLOW (commit ID: $commit_name)${normal}"
#    echo ""
#    #check on PWD
#    project_path=$(dirname "$PWD")
#    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
#        project_found="1"
#        project_name=$(basename "$PWD")
#        #echo ""
#        #echo "${bold}Please, choose your $WORKFLOW project:${normal}"
#        #echo ""
#        #echo $project_name
#        #echo ""
#    fi
#    #project_dialog (forgotten mandatory 1)
#    if [[ $project_found = "0" ]]; then
#        #echo ""
#        echo "${bold}Please, choose your $WORKFLOW project:${normal}"
#        echo ""
#        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
#        project_found=$(echo "$result" | sed -n '1p')
#        project_name=$(echo "$result" | sed -n '2p')
#        multiple_projects=$(echo "$result" | sed -n '3p')
#        if [[ $multiple_projects = "0" ]]; then
#            echo $project_name
#        fi
#        echo ""
#    fi
#    #platform_dialog (forgotten mandatory 2)
#    if [[ $platform_found = "0" ]]; then
#        #echo ""
#        echo "${bold}Please, choose your platform:${normal}"
#        echo ""
#        result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
#        platform_found=$(echo "$result" | sed -n '1p')
#        platform_name=$(echo "$result" | sed -n '2p')
#        multiple_platforms=$(echo "$result" | sed -n '3p')
#        if [[ $multiple_platforms = "0" ]]; then
#            echo $platform_name
#            #echo ""
#        fi
#        echo ""
#    fi
#fi

#cleanup bitstreams folder
if [ -e "$BITSTREAMS_PATH/foo" ]; then
    sudo $CLI_PATH/common/rm "$BITSTREAMS_PATH/foo"
fi

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"
SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
DRIVER_DIR="$DIR/open-nic-driver"

#check if project exists
if ! [ -d "$DIR" ]; then
    #echo ""
    echo "You must create your project first! Please, use sgutil new $WORKFLOW"
    echo ""
    exit
fi

#platform_name to FDEV_NAME
FDEV_NAME=$(echo "$platform_name" | cut -d'_' -f2)

#define shells
library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
#commit_shell="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$DIR/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#check on shell
compile="0"
if [ ! -e "$project_shell" ]; then
    compile="1"
elif [ -e "$project_shell" ] && [ "$project_name" != "validate_opennic.$commit_name_driver.$FDEV_NAME.$vivado_version" ]; then
    echo "${bold}The shell ${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit already exists. Do you want to remove it and compile it again (y/n)?${normal}"
    while true; do
        read -p "" yn
        case $yn in
            "y")
                rm -f $project_shell 
                compile="1"
                break
                ;;
            "n") 
                #compile="0"
                break
                ;;
        esac
    done
    echo ""
fi

#compile shell
if [ "$compile" = "1" ]; then 
    #echo ""
    echo "${bold}Shell compilation (commit ID: $commit_name)${normal}"
    echo ""
    echo "vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1"
    cd $SHELL_BUILD_DIR
    vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1
    echo ""

    #copy and send email
    if [ -f "$DIR/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BIT_NAME" ]; then
        #copy to project
        cp "$DIR/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BIT_NAME" "$project_shell"
        #print message
        echo "${bold}${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit is done!${normal}"
        echo ""
        #send email
        user_email=$USER@ethz.ch
        echo "Subject: Good news! sgutil build opennic (${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit) is done!" | sendmail $user_email
    fi
fi

#compile driver
#echo ""
echo "${bold}Driver compilation (commit ID: $commit_name_driver)${normal}"
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

#echo ""
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
BIT_NAME="open_nic_shell.bit"
DRIVER_NAME="onic.ko"
BITSTREAMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH BITSTREAMS_PATH)
NUM_JOBS="16"

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

#check if workflow exists
if ! [ -d "$MY_PROJECTS_PATH/$WORKFLOW/" ]; then
    echo ""
    echo "You must create your project first! Please, use sgutil new $WORKFLOW"
    echo ""
    exit
fi

#inputs
read -a flags <<< "$@"

#check on flags
commit_found=""
commit_name=""
project_found=""
project_name=""
platform_found=""
platform_name=""
if [ "$flags" = "" ]; then
    #check on PWD
    project_path=$(dirname "$PWD")
    commit_name=$(basename "$project_path")
    project_found="0"
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
        commit_found="1"
        project_found="1"
        project_name=$(basename "$PWD")
    elif [ "$commit_name" = "$WORKFLOW" ]; then
        commit_found="1"
        commit_name="${PWD##*/}"
    else
        commit_found="1"
        commit_name=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
    fi
    #header (1/2)
    echo ""
    echo "${bold}sgutil build $WORKFLOW (commit ID: $commit_name)${normal}"
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
    #platform_dialog
    echo ""
    echo "${bold}Please, choose your platform:${normal}"
    echo ""
    result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
    platform_found=$(echo "$result" | sed -n '1p')
    platform_name=$(echo "$result" | sed -n '2p')
    multiple_platforms=$(echo "$result" | sed -n '3p')
    if [[ $multiple_platforms = "0" ]]; then
        echo $platform_name
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
    exists=$(gh api repos/Xilinx/open-nic-shell/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    #forbidden combinations
    #if [ "$commit_found" = "0" ]; then 
    #    commit_found="1"
    #    commit_name=$(cat $CLI_PATH/constants/ONIC_SHELL_COMMIT)
    #elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
    #    $CLI_PATH/sgutil program $WORKFLOW -h
    #    exit
    #el
    if [ "$commit_found" = "1" ] && [ "$exists" = "0" ]; then 
        echo ""
        echo "Sorry, the commit ID ${bold}$commit_name${normal} does not exist on the repository."
        echo ""
        exit
    fi
    #project_dialog_check
    result="$("$CLI_PATH/common/project_dialog_check" "${flags[@]}")"
    project_found=$(echo "$result" | sed -n '1p')
    project_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]); then 
        $CLI_PATH/sgutil build $WORKFLOW -h
        exit
    fi
    #platform_dialog_check
    result="$("$CLI_PATH/common/platform_dialog_check" "${flags[@]}")"
    platform_found=$(echo "$result" | sed -n '1p')
    platform_name=$(echo "$result" | sed -n '2p')    
    #forbidden combinations
    if ([ "$platform_found" = "1" ] && [ "$platform_name" = "" ]) || ([ "$platform_found" = "1" ] && [ ! -d "$XILINX_PLATFORMS_PATH/$platform_name" ]); then
        $CLI_PATH/sgutil build $WORKFLOW -h
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil build $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    #check on PWD
    project_path=$(dirname "$PWD")
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
        project_found="1"
        project_name=$(basename "$PWD")
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
    fi
    #platform_dialog (forgotten mandatory 2)
    if [[ $platform_found = "0" ]]; then
        #echo ""
        echo "${bold}Please, choose your platform:${normal}"
        echo ""
        result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
        platform_found=$(echo "$result" | sed -n '1p')
        platform_name=$(echo "$result" | sed -n '2p')
        multiple_platforms=$(echo "$result" | sed -n '3p')
        if [[ $multiple_platforms = "0" ]]; then
            echo $platform_name
        fi
    fi
fi

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

# check if project exists
if ! [ -d "$DIR" ]; then
    echo ""
    echo "You must create your project first! Please, use sgutil new $WORKFLOW"
    echo ""
    exit
fi

#platform_name to FDEV_NAME
FDEV_NAME=$(echo "$platform_name" | cut -d'_' -f2)

#define directories (2)
SHELL_BUILD_DIR="$DIR/script"
DRIVER_DIR="$DIR/open-nic-driver"
#APP_BUILD_DIR="$DIR/examples_sw/apps/$config_sw/build"

#check on bitstream in MY_PROJECTS_PATH
if ! [ -e "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit" ]; then
    #check on bitstream in BITSTREAMS_PATH
    if [ -e "$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit" ]; then
        cp "$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit" "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
        cp "$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.ltx" "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.ltx"
    else
        #create folder as root
        if ! [ -d "$BITSTREAMS_PATH/$WORKFLOW/$commit_name" ]; then
            sudo $CLI_PATH/common/mkdir "$BITSTREAMS_PATH/$WORKFLOW/$commit_name"
        fi

        #shell compilation
        echo ""
        echo "${bold}OpenNIC shell compilation (commit ID: $commit_name):${normal}"
        echo ""
        echo "vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs 16 -impl 1"
        echo ""
        cd $SHELL_BUILD_DIR
        vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1

        #ls ../build/au55c/open_nic_shell/open_nic_shell.runs/impl_1/open_nic_shell.bit
        
        #copy to project
        cp "$DIR/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BIT_NAME" "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
        cp "$DIR/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/${BIT_NAME%.bit}.ltx" "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.ltx"

        #copy to BITSTREAM_PATH (as root)
        sudo $CLI_PATH/common/cp "$DIR/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BIT_NAME" "$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
        sudo $CLI_PATH/common/cp "$DIR/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/${BIT_NAME%.bit}.ltx" "$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.ltx"
            
        #remove all other build temporal folders
        rm -rf $DIR/build

        #send email at the end
        user_email=$USER@ethz.ch
        echo "Subject: Good news! sgutil build opennic ($project_name / -DFDEV_NAME=$FDEV_NAME) is done!" | sendmail $user_email
    fi
else
    echo ""
    echo "${bold}OpenNIC shell compilation (commit ID: $commit_name):${normal}"
    echo ""
    echo "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit shell already exists!"
fi

#driver compilation happens everytime (delete first)
if ! [ -e "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$DRIVER_NAME" ]; then
    rm $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$DRIVER_NAME
fi

#make driver
echo ""
echo "${bold}Driver compilation:${normal}"
echo ""
echo "cd $DRIVER_DIR && make"
echo ""
cd $DRIVER_DIR && make

#copy driver
cp $DRIVER_DIR/$DRIVER_NAME $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$DRIVER_NAME

#remove drivier files (generated while compilation)
rm $DRIVER_DIR/Module.symvers
rm $DRIVER_DIR/hwmon
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
rm -rf $DRIVER_DIR/qdma_access
#rm -rf $DRIVER_DIR/eci
#rm -rf $DRIVER_DIR/pci
    
#application compilation happens everytime
#echo ""
#echo "${bold}Application compilation:${normal}"
#echo ""
#echo "/usr/bin/cmake ../../../ -DEXAMPLE=$config_sw && make"
#echo ""
#if ! [ -d "$APP_BUILD_DIR" ]; then
#    mkdir $APP_BUILD_DIR
#fi
#cd $APP_BUILD_DIR
#/usr/bin/cmake ../../../ -DEXAMPLE=$config_sw && make

#move compiled application (remove first)
#if [ -d "$DIR/build_dir.$config_sw/" ]; then
#    rm -rf $DIR/build_dir.$config_sw/
#fi
#mv $APP_BUILD_DIR $DIR/build_dir.$config_sw/

echo ""
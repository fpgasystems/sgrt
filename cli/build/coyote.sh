#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="coyote"
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)
BIT_NAME="cyt_top.bit"
DRIVER_NAME="coyote_drv.ko"
BITSTREAMS_PATH="$CLI_PATH/bitstreams" #$($CLI_PATH/common/get_constant $CLI_PATH BITSTREAMS_PATH)

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
    #commit dialog
    #commit_found="1"
    #commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
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
        commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
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
    echo ""
    #platform_dialog
    echo "${bold}Please, choose your platform:${normal}"
    echo ""
    result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
    platform_found=$(echo "$result" | sed -n '1p')
    platform_name=$(echo "$result" | sed -n '2p')
    multiple_platforms=$(echo "$result" | sed -n '3p')
    if [[ $multiple_platforms = "0" ]]; then
        echo $platform_name
    fi
    echo ""
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

#check if project exists
if ! [ -d "$DIR" ]; then
    echo ""
    echo "You must create your project first! Please, use sgutil new $WORKFLOW"
    echo ""
    exit
fi

#cleanup bitstreams folder
if [ -e "$BITSTREAMS_PATH/foo" ]; then
    sudo $CLI_PATH/common/rm "$BITSTREAMS_PATH/foo"
fi

#platform_name to FDEV_NAME
FDEV_NAME=$(echo "$platform_name" | cut -d'_' -f2)

config_hw="static"
config_sw="perf_local"

#temporaly handle configs (like in sgutil validate coyote)
if ! [ -d "$DIR/configs/" ]; then
    mkdir $DIR/configs/
fi
cd $DIR/configs/
touch config_$config_sw
case "$config_hw" in
    static) 
        echo "BUILD_STATIC = 1;" >> config_$config_sw
        echo "BUILD_SHELL = 0;"  >> config_$config_sw
        echo "COMP_CORES = 40;"  >> config_$config_sw
        echo "N_REGIONS = 3;"    >> config_$config_sw
        echo "EN_STRM = 1;"      >> config_$config_sw
        echo "EN_MEM = 1;"       >> config_$config_sw
        ;;
    *)
        echo ""
        echo "Unknown configuration."
        echo ""
    ;;  
esac

#define directories (2)
SHELL_BUILD_DIR="$DIR/examples_hw/apps/build"
DRIVER_DIR="$DIR/driver"
APP_BUILD_DIR="$DIR/examples_sw/apps/$config_sw/build"

#define shells
library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#compile shell
if [ -e "$library_shell" ]; then
    cp "$library_shell" "$project_shell"
    cp "${library_shell/.bit/.ltx}" "${project_shell/.bit/.ltx}"
elif ! [ -e "$project_shell" ]; then
    #echo ""
    echo "${bold}Coyote $config_hw shell compilation (commit ID: $commit_name):${normal}"
    echo ""
    echo "/usr/bin/cmake ../../ -DEXAMPLE=$config_hw -DFDEV_NAME=$FDEV_NAME"
    echo ""
    mkdir $SHELL_BUILD_DIR
    
    cd $SHELL_BUILD_DIR
    /usr/bin/cmake ../../ -DEXAMPLE=$config_hw -DFDEV_NAME=$FDEV_NAME 

    #generate bitstream
    echo ""
    echo "${bold}Coyote shell bitstream generation:${normal}"
    echo ""
    echo "make project && make bitgen"
    echo ""
    make project && make bitgen

    #copy and send email
    if [ -f "$SHELL_BUILD_DIR/bitstreams/$BIT_NAME" ]; then
        #copy to project
        cp "$SHELL_BUILD_DIR/bitstreams/$BIT_NAME" "$project_shell"
        cp "$SHELL_BUILD_DIR/bitstreams/${BIT_NAME%.bit}.ltx" "${project_shell/.bit/.ltx}" #"$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.ltx"
        #send email
        user_email=$USER@ethz.ch
        echo "Subject: Good news! sgutil build coyote ($project_name / -DFDEV_NAME=$FDEV_NAME) is done!" | sendmail $user_email
    fi
fi

#compile driver
echo ""
echo "${bold}Driver compilation:${normal}"
echo ""
echo "cd $DRIVER_DIR && make"
echo ""
cd $DRIVER_DIR && make

#copy driver
cp -f $DRIVER_DIR/$DRIVER_NAME $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$DRIVER_NAME

#remove drivier files (generated while compilation)
rm $DRIVER_DIR/coyote_drv*
rm $DRIVER_DIR/fpga_dev.o
rm $DRIVER_DIR/fpga_drv.o
rm $DRIVER_DIR/fpga_fops.o
rm $DRIVER_DIR/fpga_mmu.o
rm $DRIVER_DIR/fpga_sysfs.o
rm $DRIVER_DIR/modules.order
rm $DRIVER_DIR/fpga_gup.o
rm $DRIVER_DIR/fpga_hmm.o
rm $DRIVER_DIR/fpga_hw.o
rm $DRIVER_DIR/fpga_pops.o
rm $DRIVER_DIR/fpga_pr.o
rm $DRIVER_DIR/fpga_uisr.o
rm $DRIVER_DIR/Module.symvers
    
#compile application
echo ""
echo "${bold}Application compilation:${normal}"
echo ""
echo "/usr/bin/cmake ../../../ -DEXAMPLE=$config_sw && make"
echo ""
if ! [ -d "$APP_BUILD_DIR" ]; then
    mkdir $APP_BUILD_DIR
fi
cd $APP_BUILD_DIR
/usr/bin/cmake ../../../ -DEXAMPLE=$config_sw && make

#move compiled application (remove first)
if [ -d "$DIR/build_dir.$config_sw/" ]; then
    rm -rf $DIR/build_dir.$config_sw/
fi
mv $APP_BUILD_DIR $DIR/build_dir.$config_sw/

echo ""
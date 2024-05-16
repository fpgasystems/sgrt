#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
API_PATH="$(dirname "$CLI_PATH")/api"
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="vitis"
BUILD_FILE="sp"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"

#set environmental variables
#export API_PATH="$(dirname "$CLI_PATH")/api"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on valid XRT and Vivado version
xrt_version=$($CLI_PATH/common/get_xilinx_version xrt)
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)

if [ -z "$xrt_version" ] || [ -z "$vivado_version" ] || ([ "$xrt_version" != "$vivado_version" ]); then #if [ -z "$(echo $xrt_version)" ] || [ -z "$(echo $vivado_version)" ] || ([ "$xrt_version" != "$vivado_version" ]); then
    echo ""
    echo "Please, source valid XRT and Vivado versions for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check if workflow exists
if ! [ -d "$MY_PROJECTS_PATH/$WORKFLOW/" ]; then
    echo ""
    echo "You must create your project first! Please, use sgutil new vitis"
    echo ""
    exit
fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

echo "HEEEEEE $MAX_DEVICES"

#inputs
read -a flags <<< "$@"

#check on flags
project_found=""
project_name=""
target_found=""
target_name=""
#platform_found=""
#platform_name=""
#xclbin_found=""
#xclbin_name=""
if [ "$flags" = "" ]; then
    #header (1/2)
    echo ""
    echo "${bold}sgutil build vitis${normal}"
    #project_dialog
    echo ""
    echo "${bold}Please, choose your $WORKFLOW project:${normal}"
    echo ""
    result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW) #$USER $WORKFLOW
    project_found=$(echo "$result" | sed -n '1p')
    project_name=$(echo "$result" | sed -n '2p')
    multiple_projects=$(echo "$result" | sed -n '3p')
    if [[ $multiple_projects = "0" ]]; then
        echo $project_name
    fi
    #check if host has been compiled already
    target_host="0"
    if [ -e "$MY_PROJECTS_PATH/$WORKFLOW/$project_name/host" ]; then
        target_host="1"
    fi
    #target_dialog
    echo ""
    echo "${bold}Please, choose binary's build target:${normal}"
    echo ""
    target_name=$($CLI_PATH/common/target_dialog $target_host)
    #platform/xclbin dialogs
    #if [ "$target_name" != "host" ]; then
        #platform_dialog
        #echo ""
        #echo "${bold}Please, choose your platform:${normal}"
        #echo ""
        #result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
        #platform_found=$(echo "$result" | sed -n '1p')
        #platform_name=$(echo "$result" | sed -n '2p')
        #multiple_platforms=$(echo "$result" | sed -n '3p')
        #if [[ $multiple_platforms = "0" ]]; then
        #    echo $platform_name
        #fi
        #xclbin_dialog
        #echo ""
        #echo "${bold}Please, choose your XCLBIN:${normal}"
        #echo ""
        #result=$($CLI_PATH/common/xclbin_dialog $MY_PROJECTS_PATH/$WORKFLOW/$project_name) #$USER $WORKFLOW
        #xclbin_found=$(echo "$result" | sed -n '1p')
        #xclbin_name=$(echo "$result" | sed -n '2p')
        #multiple_xclbins=$(echo "$result" | sed -n '3p')
        #if [[ $multiple_xclbins = "0" ]]; then
        #    echo $xclbin_name
        #fi
    #fi
else
    #project_dialog_check
    result="$("$CLI_PATH/common/project_dialog_check" "${flags[@]}")"
    project_found=$(echo "$result" | sed -n '1p')
    project_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$project_name" ]); then 
        $CLI_PATH/sgutil build vitis -h
        exit
    fi
    #target_dialog_check
    result="$("$CLI_PATH/common/target_dialog_check" "${flags[@]}")"
    target_found=$(echo "$result" | sed -n '1p')
    target_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [[ "$target_found" = "1" && ! ( "$target_name" = "host" || "$target_name" = "sw_emu" || "$target_name" = "hw_emu" || "$target_name" = "hw" ) ]]; then
        $CLI_PATH/sgutil build vitis -h
        exit
    fi
    #platform_dialog_check
    #result="$("$CLI_PATH/common/platform_dialog_check" "${flags[@]}")"
    #platform_found=$(echo "$result" | sed -n '1p')
    #platform_name=$(echo "$result" | sed -n '2p')    
    ##forbidden combinations (1/2)
    #if ([ "$platform_found" = "1" ] && [ "$platform_name" = "" ]) || ([ "$platform_found" = "1" ] && [ ! -d "$XILINX_PLATFORMS_PATH/$platform_name" ]); then
    #    $CLI_PATH/sgutil build vitis -h
    #    exit
    #fi
    #forbidden combinations (2/2)
    if ([ "$target_found" = "1" ] && [ "$target_name" = "host" ]) && [ "$platform_found" = "1" ]; then 
        $CLI_PATH/sgutil build vitis -h
        exit
    fi
    #xclbin_dialog_check
    #result="$("$CLI_PATH/common/xclbin_dialog_check" "${flags[@]}")"
    #xclbin_found=$(echo "$result" | sed -n '1p')
    #xclbin_name=$(echo "$result" | sed -n '2p')
    ##forbidden combinations
    #if ([ "$xclbin_found" = "1" ] && ([ "$xclbin_name" = "" ] || [ ! -f "$MY_PROJECTS_PATH/$WORKFLOW/$project_name/src/xclbin/$xclbin_name.cpp" ])) || ([ "$xclbin_found" = "1" ] && [ "$target_name" = "host" ]); then 
    #    $CLI_PATH/sgutil build vitis -h
    #    exit
    #fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil build vitis${normal}"
    #project_dialog (forgotten mandatory 1)
    if [[ $project_found = "0" ]]; then
        echo ""
        echo "${bold}Please, choose your $WORKFLOW project:${normal}"
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW) #$USER $WORKFLOW
        project_found=$(echo "$result" | sed -n '1p')
        project_name=$(echo "$result" | sed -n '2p')
        multiple_projects=$(echo "$result" | sed -n '3p')
        if [[ $multiple_projects = "0" ]]; then
            echo $project_name
        fi
    fi
    #check if host has been compiled already
    target_host="0"
    if [ -e "$MY_PROJECTS_PATH/$WORKFLOW/$project_name/host" ]; then
        target_host="1"
    fi
    #target_dialog (forgotten mandatory 3)
    if [[ $target_found = "0" ]]; then
        echo ""
        echo "${bold}Please, choose binary's execution target:${normal}"
        echo ""
        #target_name=$($CLI_PATH/common/target_dialog)
        target_name=$($CLI_PATH/common/target_dialog $target_host)
    fi
    #platform and xclbin_dialog (forgotten mandatory 2)
    #if [ "$target_name" != "host" ]; then
        ##platform_dialog
        #if [[ $platform_found = "0" ]]; then
        #    echo ""
        #    echo "${bold}Please, choose your platform:${normal}"
        #    echo ""
        #    result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
        #    platform_found=$(echo "$result" | sed -n '1p')
        #    platform_name=$(echo "$result" | sed -n '2p')
        #    multiple_platforms=$(echo "$result" | sed -n '3p')
        #    if [[ $multiple_platforms = "0" ]]; then
        #        echo $platform_name
        #    fi
        #fi
        #xclbin_dialog
        #if [[ $xclbin_found = "0" ]]; then
        #    echo ""
        #    echo "${bold}Please, choose your XCLBIN:${normal}"
        #    echo ""
        #    result=$($CLI_PATH/common/xclbin_dialog $MY_PROJECTS_PATH/$WORKFLOW/$project_name)
        #    xclbin_found=$(echo "$result" | sed -n '1p')
        #    xclbin_name=$(echo "$result" | sed -n '2p')
        #    multiple_xclbins=$(echo "$result" | sed -n '3p')
        #    if [[ $multiple_xclbins = "0" ]]; then
        #        echo $xclbin_name
        #    fi
        #fi
    #fi
fi

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name"

#check for project directory
if ! [ -d "$DIR" ]; then
    echo ""
    echo "$DIR is not a valid --project name!"
    echo ""
    exit
fi

#create [or select] a configuration (select moved to run)
cd $DIR/configs/
if [[ $(ls -l | wc -l) = 2 ]]; then
    #only config_000 exists and we create config_kernel and config_001
    #we compile config_add (in case there were changes)
    #cd $DIR/src
    #g++ -std=c++17 config_add.cpp -o ../config_add >&/dev/null
    cd $DIR
    ./config_add
    #cp -fr $DIR/configs/config_001.hpp $DIR/configs/config_000.hpp
    #config="config_001"
fi

#change directory
echo ""
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#host compilation
if [ "$target_host" = "0" ] || [ "$target_name" = "host" ]; then
    
    #host compilation (should be equivalent to "make host")
    echo "${bold}host.cpp compilation:${normal}"
    echo ""
    
    #print application compilation command
    echo "g++ -o host \
    $MY_PROJECTS_PATH/$WORKFLOW/common/includes/cmdparser/cmdlineparser.cpp \
    $MY_PROJECTS_PATH/$WORKFLOW/common/includes/logger/logger.cpp \
    src/host.cpp \
    src/host/*.cpp \
    $API_PATH/host/*.cpp \
    $API_PATH/common/*.cpp \
    -I$API_PATH \
    -I$API_PATH/common \
    -I$XRT_PATH/include -I$XILINX_VIVADO/include -Wall -O0 -g -std=c++1y \
    -I$MY_PROJECTS_PATH/$WORKFLOW/common/includes/cmdparser \
    -I$MY_PROJECTS_PATH/$WORKFLOW/common/includes/logger \
    -fmessage-length=0 -L$XRT_PATH/lib -pthread -lOpenCL -lrt -lstdc++ -luuid -lxrt_coreutil"

    #run application compilation command
    g++ -o host \
    $MY_PROJECTS_PATH/$WORKFLOW/common/includes/cmdparser/cmdlineparser.cpp \
    $MY_PROJECTS_PATH/$WORKFLOW/common/includes/logger/logger.cpp \
    src/host.cpp \
    src/host/*.cpp \
    $API_PATH/host/*.cpp \
    $API_PATH/common/*.cpp \
    -I$API_PATH \
    -I$API_PATH/common \
    -I$XRT_PATH/include -I$XILINX_VIVADO/include -Wall -O0 -g -std=c++1y \
    -I$MY_PROJECTS_PATH/$WORKFLOW/common/includes/cmdparser \
    -I$MY_PROJECTS_PATH/$WORKFLOW/common/includes/logger \
    -fmessage-length=0 -L$XRT_PATH/lib -pthread -lOpenCL -lrt -lstdc++ -luuid -lxrt_coreutil
    
    echo ""
fi

#xclbin compilation
if [[ "$target_name" == "sw_emu" || "$target_name" == "hw_emu" || "$target_name" == "hw" ]]; then

    #read from sp (we build all the xclbins defined in sp)
    declare -a device_indexes
    declare -a kernel_names

    while read -r line; do
        column_1=$(echo "$line" | awk '{print $1}')
        column_2=$(echo "$line" | awk '{print $2}')

        #check if column_1 is a device_index (ann integer between 1 and MAX_DEVICES)
        if [[ $column_1 =~ ^[1-9][0-9]*$ && $column_1 -le $MAX_DEVICES ]]; then
            device_indexes+=("$column_1")
            kernel_names+=("$column_2")
        #else
        #    echo "Column 1 is not a valid integer between 1 and $MAX_DEVICES: $column_1"
        #    # Handle the error or skip this line
        #    continue
        fi
        #device_indexes+=("$column_1")
        #kernel_names+=("$column_2")
    done < "$DIR/$BUILD_FILE"

    #check on sp
    if [ "${#kernel_names[@]}" -eq 0 ]; then #|| [ "${#compute_units_num[@]}" -eq 0 ] || [ "${#compute_units_names[@]}" -eq 0 ]
        echo ""
        echo "Please, review sp configuration file!"
        echo ""
        exit
    fi

    #generate .cfg for all xclbins defined in sp
    $CLI_PATH/common/get_xclbin_cfg $DIR/$BUILD_FILE $DIR > /dev/null #$DIR/nk

    echo "${bold}XCLBIN compilation and linking:${normal}"
    echo ""

    #compile for each xclbin_name_i
    for ((i = 0; i < ${#kernel_names[@]}; i++)); do
    
        #map to sp
        device_index_i="${device_indexes[i]}"
        kernel_name_i="${kernel_names[i]}"

        #derive the xclbin name
        xclbin_name_i=$(echo "$kernel_name_i" | cut -d'_' -f1)

        #platform can be potentially different for each FPGA index
        platform_name_i=$($CLI_PATH/get/get_fpga_device_param $device_index_i platform)
        
        #define directories (2)
        #XCLBIN_BUILD_DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name/build_dir.$xclbin_i.$target_name.$platform_name_i"
        XCLBIN_BUILD_DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name/$xclbin_name_i.$target_name.$platform_name_i"

        #build/print upon existing directory
        if ! [ -d "$XCLBIN_BUILD_DIR" ]; then

            #print .cfg contents
            echo "${bold}Using $xclbin_name_i.cfg configuration file:${normal}"
            echo ""
            cat $xclbin_name_i.cfg
            echo ""
            
            #echo "${bold}XCLBIN $xclbin_i compilation and linking:${normal}"
            #echo ""

            # XCLBIN_BUILD_DIR does not exist
            #echo ""
            echo "make build TARGET=$target_name PLATFORM=$platform_name_i API_PATH=$API_PATH XCLBIN_NAME=$xclbin_name_i" 
            echo ""
            export CPATH="/usr/include/x86_64-linux-gnu" #https://support.xilinx.com/s/article/Fatal-error-sys-cdefs-h-No-such-file-or-directory?language=en_US
            eval "make build TARGET=$target_name PLATFORM=$platform_name_i API_PATH=$API_PATH XCLBIN_NAME=$xclbin_name_i"
            echo ""

            #copy device_config.hpp and .cfg for reference (will be compared to _device_config.hpp and .cfg)
            cp $DIR/configs/device_config.hpp $XCLBIN_BUILD_DIR/_${xclbin_name_i}_device_config.hpp
            cp $xclbin_name_i.cfg $XCLBIN_BUILD_DIR/_${xclbin_name_i}.cfg

            #send email at the end
            if [ "$target_name" = "hw" ] && [ -f "$XCLBIN_BUILD_DIR/$xclbin_name_i.xclbin" ]; then
                user_email=$USER@ethz.ch
                echo "Subject: Good news! sgutil build vitis ($project_name / TARGET=$target_name / PLATFORM=$platform_name_i / XCLBIN=$xclbin_name_i) is done!" | sendmail $user_email
            fi

        else

            echo "The XCLBIN $xclbin_name_i.$target_name.$platform_name_i already exists!"
            echo ""

        fi

    done

    #manage compilation logs
    if ! [ -d "$DIR/logs" ]; then
        mkdir $DIR/logs
    fi
    
    #mv $DIR/v++_*.log $DIR/logs

    #move v++ logs
    shopt -s nullglob
    vpp_logs=($DIR/v++_*.log)
    shopt -u nullglob

    if [ ${#vpp_logs[@]} -gt 0 ]; then
        for file in "${vpp_logs[@]}"; do
            mv "$file" "$DIR/logs/"
        done
    fi

    #move other logs
    if [ -f "$DIR/xcd.log" ]; then
        mv $DIR/xcd.log $DIR/logs
    fi
    
    #remove sp_aux
    #if [ -f "sp_aux" ]; then
    #    rm "sp_aux"
    #fi

    #copy device_config.hpp to project folder
    #cp $DIR/configs/device_config.hpp $DIR/_device_config.hpp #$XCLBIN_BUILD_DIR/$xclbin_i.parameters

fi
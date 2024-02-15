#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="vitis"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA)
acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit
fi

#check on valid XRT version
#if [ ! -d $XRT_PATH ]; then
#    echo ""
#    echo "Please, source a valid XRT and Vitis version for ${bold}$hostname!${normal}"
#    echo ""
#    exit 1
#fi

#check on valid XRT and Vivado version
xrt_version=$($CLI_PATH/common/get_xilinx_version xrt)

if [ -z "$xrt_version" ]; then #if [ -z "$(echo $xrt_version)" ]; then
    echo ""
    echo "Please, source a valid XRT version for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#check if workflow exists
if ! [ -d "$MY_PROJECTS_PATH/$WORKFLOW/" ]; then
    echo ""
    echo "You must build and/or program (target = hw) your project/device first! Please, use sgutil build/program vitis"
    echo ""
    exit
fi

#inputs
read -a flags <<< "$@"

#check on flags
project_found=""
project_name=""
target_found=""
target_name=""
#device_found=""
#device_index=""
if [ "$flags" = "" ]; then
    #header (1/2)
    echo ""
    echo "${bold}sgutil run vitis${normal}"
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
    #target_dialog
    echo ""
    echo "${bold}Please, choose binary's execution target:${normal}"
    echo ""
    target_name=$($CLI_PATH/common/target_dialog)
    #platform or device dialog
    if [ "$target_name" = "sw_emu" ] || [ "$target_name" = "hw_emu" ]; then
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
        #set default device
        #device_found="1"
        #device_index="1"
    #elif [ "$target_name" = "hw" ]; then 
    #    #device_dialog
    #    if [[ $multiple_devices = "0" ]]; then
    #        device_found="1"
    #        device_index="1"
    #    else
    #        echo ""
    #        echo "${bold}Please, choose your device:${normal}"
    #        echo ""
    #        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
    #        device_found=$(echo "$result" | sed -n '1p')
    #        device_index=$(echo "$result" | sed -n '2p')
    #    fi    
    fi    
else
    #project_dialog_check
    result="$("$CLI_PATH/common/project_dialog_check" "${flags[@]}")"
    project_found=$(echo "$result" | sed -n '1p')
    project_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$project_name" ]); then 
        $CLI_PATH/sgutil run vitis -h
        exit
    fi
    #target_dialog_check
    result="$("$CLI_PATH/common/target_dialog_check" "${flags[@]}")"
    target_found=$(echo "$result" | sed -n '1p')
    target_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [[ "$target_found" = "1" && ! ( "$target_name" = "sw_emu" || "$target_name" = "hw_emu" || "$target_name" = "hw" ) ]]; then
        $CLI_PATH/sgutil run vitis -h
        exit
    fi
    #platform_dialog_check
    result="$("$CLI_PATH/common/platform_dialog_check" "${flags[@]}")"
    platform_found=$(echo "$result" | sed -n '1p')
    platform_name=$(echo "$result" | sed -n '2p')    
    #forbidden combinations
    if ([ "$platform_found" = "1" ] && [ "$platform_name" = "" ]) || ([ "$platform_found" = "1" ] && [ ! -d "$XILINX_PLATFORMS_PATH/$platform_name" ]); then
        $CLI_PATH/sgutil run vitis -h
        exit
    fi
    #device_dialog_check
    #result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    #device_found=$(echo "$result" | sed -n '1p')
    #device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    #if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
    #    $CLI_PATH/sgutil run vitis -h
    #    exit
    #fi
    #forbidden target/device combinations (1)
    #if [[ "$target_name" = "sw_emu" || "$target_name" = "hw_emu" ]] && [[ "$device_found" = "1" ]]; then
    #    $CLI_PATH/sgutil run vitis -h
    #    exit
    #fi
    #forbidden target/device combinations (2)
    if [[ "$target_name" = "hw" ]] && [[ "$platform_found" = "1" ]]; then
        $CLI_PATH/sgutil run vitis -h
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil run vitis${normal}"
    echo ""
    #project_dialog (forgotten mandatory 1)
    if [[ $project_found = "0" ]]; then
        #echo ""
        echo "${bold}Please, choose your $WORKFLOW project:${normal}"
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW) #$USER $WORKFLOW
        project_found=$(echo "$result" | sed -n '1p')
        project_name=$(echo "$result" | sed -n '2p')
        multiple_projects=$(echo "$result" | sed -n '3p')
        if [[ $multiple_projects = "0" ]]; then
            echo $project_name
        fi
        #echo ""
    fi
    #target_dialog (forgotten mandatory 2)
    #if [[ $target_found = "0" ]] && [[ $device_found = "0" ]]; then
    #    echo "${bold}Please, choose binary's execution target:${normal}"
    #    echo ""
    #    target_name=$($CLI_PATH/common/target_dialog)
    #elif [[ $target_found = "0" ]] && [[ $device_found = "1" ]]; then
    #    #echo ""
    #    target_name="hw"
    #fi
    if [[ $target_found = "0" ]]; then
        echo "${bold}Please, choose binary's execution target:${normal}"
        echo ""
        target_name=$($CLI_PATH/common/target_dialog)
    fi
    #platform or device dialog
    if [ "$target_name" = "sw_emu" ] || [ "$target_name" = "hw_emu" ]; then
        #platform_dialog (forgotten mandatory emu)
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
        ##set default device
        #device_found="1"
        #device_index="1"
    #elif [ "$target_name" = "hw" ]; then 
    #    #device_dialog (forgotten mandatory hw)
    #    if [[ $multiple_devices = "0" ]]; then
    #        device_found="1"
    #        device_index="1"
    #    elif [[ $device_found = "0" ]]; then
    #        echo ""
    #        echo "${bold}Please, choose your device:${normal}"
    #        echo ""
    #        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
    #        device_found=$(echo "$result" | sed -n '1p')
    #        device_index=$(echo "$result" | sed -n '2p')
    #        echo ""
    #    fi
    fi
fi

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name"

#check if project exists
if ! [ -d "$DIR" ]; then
    echo ""
    echo "$DIR is not a valid --project name!"
    echo ""
    exit
fi

#select a configuration
cd $DIR/configs/
#if [[ $(ls -l | wc -l) = 2 ]]; then
#    #only config_000 exists and we create config_kernel and config_001
#    #we compile create_config (in case there were changes)
#    cd $DIR/src
#    g++ -std=c++17 create_config.cpp -o ../create_config >&/dev/null
#    cd $DIR
#    ./create_config
#    #cp -fr $DIR/configs/config_001.hpp $DIR/configs/config_000.hpp
#    config="config_001"
#elif [[ $(ls -l | wc -l) = 5 ]]; then
if [[ $(ls -l | wc -l) = 5 ]]; then
    #config_000, config_kernel and config_001 exist
    #cp -fr $DIR/configs/config_001.hpp $DIR/configs/config_000.hpp
    config_id="config_001"
    echo ""
elif [[ $(ls -l | wc -l) > 5 ]]; then
    cd $DIR/configs/
    configs=( "config_"* )
    
    #remove selected files
    configs_aux=()
    for element in "${configs[@]}"; do
        if [[ $element != *"config_parameters"* && $element != *.hpp ]]; then #config_000 && $element != *.active
            configs_aux+=("$element")
        fi
    done

    echo ""
    echo "${bold}Please, choose your configuration:${normal}"
    echo ""
    PS3=""

    select config_id in "${configs_aux[@]}"; do
        if [[ -z $config_id ]]; then
            echo "" >&/dev/null
        else
            break
        fi
    done
    # copy selected config as config_000.hpp
    #cp -fr $DIR/configs/$config $DIR/configs/config_000.hpp
    echo ""
fi

#save config id
#cd $DIR/configs/
#if [ -e config_*.active ]; then
#    rm *.active
#fi
#config_id="${config%%.*}"
#touch $config_id.active


#echo "HEY!"
#echo "$config_id"
#exit

#read from sp
declare -a device_indexes
declare -a xclbin_names

while read -r line; do
    column_1=$(echo "$line" | awk '{print $1}')
    column_2=$(echo "$line" | awk '{print $2}')
    device_indexes+=("$column_1")
    xclbin_names+=("$column_2")
done < "$DIR/sp"

#check for build directories
for ((i = 0; i < ${#device_indexes[@]}; i++)); do
    #map to sp
    device_index="${device_indexes[i]}"
    xclbin_name="${xclbin_names[i]}"

    #get platform
    platform_name=$($CLI_PATH/get/get_fpga_device_param $device_index platform)

    #check for build directory
    if ! [ -d "$DIR/build_dir.$xclbin_name.$target_name.$platform_name" ]; then
        echo ""
        echo "You must build your project first! Please, use sgutil build vitis"
        echo ""
        exit
    fi
done

#get platform
#if [ "$target_name" = "hw" ]; then 
#    platform_name=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
#fi

#xclbin_name="vadd"

#define directories (2)
#APP_BUILD_DIR="$DIR/build_dir.$xclbin_name.$target_name.$platform_name"

#check for build directory
#if ! [ -d "$APP_BUILD_DIR" ]; then
#    echo ""
#    echo "You must build your project first! Please, use sgutil build vitis"
#    echo ""
#    exit
#fi

#revert to xrt first if FPGA is already in baremetal (this is needed also for sw_emu and hw_emu, i.e. when we do not use sgutil program vitis)
#$CLI_PATH/program/revert -d $device_index

#change directory
#echo ""
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
#cd $DIR

#display configuration
cd $DIR/configs/
#config_id=$(ls *.active)
#config_id="${config_id%%.*}"

echo "${bold}You are running $config_id:${normal}"
echo ""
#cat $DIR/configs/config_000.hpp
cat $DIR/configs/$config_id
echo ""

#execution
cd $DIR
echo "${bold}Running accelerated application:${normal}"
#echo ""

case "$target_name" in
    sw_emu|hw_emu)
        #echo "./$project_name -x ./build_dir.$target_name.$platform_name/vadd.xclbin" 
        #echo ""
        #eval "./$project_name -x ./build_dir.$target_name.$platform_name/vadd.xclbin"
        #echo ""
        #echo "make run TARGET=$target_name PLATFORM=$platform_name" 
        #echo ""
        #eval "make run TARGET=$target_name PLATFORM=$platform_name"

        #create emconfig.json (this was automatically done in sgutil build vitis when using make all and not make build)
        emconfigutil --platform $platform_name --od ./_x.$xclbin_name.$target_name.$platform_name --nd 2
        echo ""

        echo "cp -rf ./_x.$xclbin_name.$target_name.$platform_name/emconfig.json ."
        echo "XCL_EMULATION_MODE=$target_name ./host $config_id" # -p $DIR # $project_name 
        echo ""
        eval "cp -rf ./_x.$xclbin_name.$target_name.$platform_name/emconfig.json ."
        eval "XCL_EMULATION_MODE=$target_name ./host $config_id" # -p $DIR # $project_name
        echo ""
        ;;
    hw)
        echo "./host $config_id" # -p $DIR # $project_name
        #echo ""
        eval "./host $config_id" # -p $DIR # $project_name
        echo ""
        ;;
esac
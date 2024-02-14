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

#inputs
read -a flags <<< "$@"

#check on flags
project_found=""
project_name=""
target_found=""
target_name=""
platform_found=""
platform_name=""
xclbin_found=""
xclbin_name=""
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
    if [ "$target_name" != "host" ]; then
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
    fi
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
    result="$("$CLI_PATH/common/platform_dialog_check" "${flags[@]}")"
    platform_found=$(echo "$result" | sed -n '1p')
    platform_name=$(echo "$result" | sed -n '2p')    
    #forbidden combinations (1/2)
    if ([ "$platform_found" = "1" ] && [ "$platform_name" = "" ]) || ([ "$platform_found" = "1" ] && [ ! -d "$XILINX_PLATFORMS_PATH/$platform_name" ]); then
        $CLI_PATH/sgutil build vitis -h
        exit
    fi
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
    if [ "$target_name" != "host" ]; then
        #platform_dialog
        if [[ $platform_found = "0" ]]; then
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
        fi
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
    fi
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
if [[ $(ls -l | wc -l) = 3 ]]; then
    #only config_000 exists and we create config_kernel and config_001
    #we compile config_add (in case there were changes)
    cd $DIR/src
    g++ -std=c++17 config_add.cpp -o ../config_add >&/dev/null
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

    #read from nk
    declare -a xclbin_names
    declare -a compute_units_num
    declare -a compute_units_names

    while read -r line; do
        column_1=$(echo "$line" | awk '{print $1}')
        column_2=$(echo "$line" | awk '{print $2}')
        column_3=$(echo "$line" | awk '{print $3}')
        xclbin_names+=("$column_1")
        compute_units_num+=("$column_2")
        compute_units_names+=("$column_3")
    done < "nk"

    for ((i = 0; i < ${#xclbin_names[@]}; i++)); do
        #map to nk
        xclbin_i="${xclbin_names[i]}"
        compute_units_num_i="${compute_units_num[i]}"
        compute_units_names_i="${compute_units_names[i]}"
    done

    #check on acap_fpga
    if [ "${#xclbin_names[@]}" -eq 0 ] || [ "${#compute_units_num[@]}" -eq 0 ] || [ "${#compute_units_names[@]}" -eq 0 ]; then
        echo ""
        echo "Please, review nk configuration file!"
        echo ""
        exit
    fi

    #compile for each xclbin_i
    #for i in "${xclbin_names[@]}"; do #xclbin_i
    for ((i = 0; i < ${#xclbin_names[@]}; i++)); do
    
        #map to nk
        xclbin_i="${xclbin_names[i]}"
        compute_units_num_i="${compute_units_num[i]}"
        compute_units_names_i="${compute_units_names[i]}"
        
        #define directories (2)
        XCLBIN_BUILD_DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name/build_dir.$xclbin_i.$target_name.$platform_name"

        #create <nk_xclbin.cfg> out of nk
        touch nk_$xclbin_i.cfg
        echo "[connectivity]" >> nk_$xclbin_i.cfg
        if [ "$compute_units_names_i" = "" ]; then
            echo "nk=$xclbin_i:$compute_units_num_i" >> nk_$xclbin_i.cfg 
        else
            echo "nk=$xclbin_i:$compute_units_num_i:$compute_units_names_i" >> nk_$xclbin_i.cfg 
        fi
        
        #move to build_dir
        #mv $xclbin_i"_config.cfg" $XCLBIN_BUILD_DIR

        echo "${bold}XCLBIN $xclbin_i compilation and linking:${normal}"
        echo ""

        if ! [ -d "$XCLBIN_BUILD_DIR" ]; then
            # XCLBIN_BUILD_DIR does not exist
            #echo "${bold}PL kernel compilation and linking: generating .xo and .xclbin:${normal}"
            #echo ""
            echo "make build TARGET=$target_name PLATFORM=$platform_name API_PATH=$API_PATH XCLBIN_NAME=$xclbin_i" 
            echo ""
            export CPATH="/usr/include/x86_64-linux-gnu" #https://support.xilinx.com/s/article/Fatal-error-sys-cdefs-h-No-such-file-or-directory?language=en_US
            eval "make build TARGET=$target_name PLATFORM=$platform_name API_PATH=$API_PATH XCLBIN_NAME=$xclbin_i"
            echo ""        

            #send email at the end
            if [ "$target_name" = "hw" ]; then
                user_email=$USER@ethz.ch
                echo "Subject: Good news! sgutil build vitis ($project_name / TARGET=$target_name / PLATFORM=$platform_name / XCLBIN=$xclbin_i) is done!" | sendmail $user_email
            fi
        else

            echo ""
            echo "The XCLBIN $xclbin_name.$target_name.$platform_name already exists!"
            echo ""

        fi

        #increase index
        #i=$(($i+1))

    done

    #echo "All compiled!"
    #exit    
    #
    #xclbin_name="vadd"
    #
    ##define directories (2)
    #XCLBIN_BUILD_DIR="$MY_PROJECTS_PATH/$WORKFLOW/$project_name/build_dir.$xclbin_name.$target_name.$platform_name"
    #
    #if ! [ -d "$XCLBIN_BUILD_DIR" ]; then
    #    # XCLBIN_BUILD_DIR does not exist
    #    echo "${bold}PL kernel compilation and linking: generating .xo and .xclbin:${normal}"
    #    echo ""
    #    echo "make build TARGET=$target_name PLATFORM=$platform_name API_PATH=$API_PATH XCLBIN_NAME=$xclbin_name" 
    #    echo ""
    #    export CPATH="/usr/include/x86_64-linux-gnu" #https://support.xilinx.com/s/article/Fatal-error-sys-cdefs-h-No-such-file-or-directory?language=en_US
    #    eval "make build TARGET=$target_name PLATFORM=$platform_name API_PATH=$API_PATH XCLBIN_NAME=$xclbin_name"
    #    echo ""        
    #
    #    #send email at the end
    #    if [ "$target_name" = "hw" ]; then
    #        user_email=$USER@ethz.ch
    #        echo "Subject: Good news! sgutil build vitis ($project_name / TARGET=$target_name / PLATFORM=$platform_name) is done!" | sendmail $user_email
    #    fi
    #else
    #    echo ""
    #    echo "${bold}The XCLBIN $xclbin_name.$target_name.$platform_name already exists. Do you want to build it again (y/n)?${normal}"
    #    while true; do
    #        read -p "" yn
    #        case $yn in
    #            "y") 
    #                #delete
    #                rm -rf $XCLBIN_BUILD_DIR
    #                
    #                #rebuild
    #                echo ""
    #                echo "${bold}PL kernel compilation and linking: generating .xo and .xclbin:${normal}"
    #                echo ""
    #                echo "make build TARGET=$target_name PLATFORM=$platform_name API_PATH=$API_PATH XCLBIN_NAME=$xclbin_name" 
    #                echo ""
    #                export CPATH="/usr/include/x86_64-linux-gnu" #https://support.xilinx.com/s/article/Fatal-error-sys-cdefs-h-No-such-file-or-directory?language=en_US
    #                eval "make build TARGET=$target_name PLATFORM=$platform_name API_PATH=$API_PATH XCLBIN_NAME=$xclbin_name"
    #                echo ""
    #
    #                #send email at the end
    #                if [ "$target_name" = "hw" ]; then
    #                    user_email=$USER@ethz.ch
    #                    echo "Subject: Good news! sgutil build vitis ($project_name / TARGET=$target_name / PLATFORM=$platform_name) is done!" | sendmail $user_email
    #                fi
    #
    #                break
    #                ;;
    #            "n") 
    #                echo ""
    #                break
    #                ;;
    #        esac
    #    done
    #    
    #fi

fi
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="coyote"
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT) #"edebb00" #"f1c6e54" #"07bf9a8" #"7f8ba4e" #"4629886"
BIT_NAME="cyt_top.bit"
DRIVER_NAME="coyote_drv.ko"

#combine ACAP and FPGA lists removing duplicates
SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST $CLI_PATH/constants/FPGA_SERVERS_LIST)

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

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA)
acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
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

if [ -z "$vivado_version" ] || [ -z "$vitis_version" ] || ([ "$vivado_version" != "$vitis_version" ]); then #if [ -z "$(echo $vivado_version)" ] || [ -z "$(echo $vitis_version)" ] || ([ "$vivado_version" != "$vitis_version" ]); then
    echo ""
    echo "Please, source valid Vivado and Vitis HLS versions for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#get vivado version from environment variable XILINX_VIVADO
vivado_version=$(basename "$XILINX_VIVADO")

#check for vivado_developers
member=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$member" = "false" ]; then
    echo ""
    echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
    echo ""
    exit
fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#create devices_acap_fpga_coyote
sudo $CLI_PATH/common/get_devices_acap_fpga_coyote

#inputs
read -a flags <<< "$@"

#create my_projects directory
if ! [ -d "$MY_PROJECTS_PATH" ]; then
    mkdir ${MY_PROJECTS_PATH}
fi

#create coyote directory
DIR="$MY_PROJECTS_PATH/$WORKFLOW"
if ! [ -d "$DIR" ]; then
    mkdir ${DIR}
fi

#header (1/1)
#echo ""
#echo "${bold}sgutil validate $WORKFLOW${normal}"

#check on flags
commit_found=""
commit_name=""
device_found=""
device_index=""
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
    echo "${bold}sgutil validate $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    #device dialog
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    else
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        #check on acap (temporal until Coyote works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            echo ""
            echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
            echo ""
            exit
        fi
    fi
else
    #commit_dialog_check
    result="$("$CLI_PATH/common/commit_dialog_check" "${flags[@]}")"
    commit_found=$(echo "$result" | sed -n '1p')
    commit_name=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
        $CLI_PATH/sgutil validate $WORKFLOW -h
        exit
    fi
    #check if commit exists
    exists=$(gh api repos/fpgasystems/Coyote/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
    #forbidden combinations
    if [ "$commit_found" = "0" ]; then 
        commit_found="1"
        commit_name=$(cat $CLI_PATH/constants/COYOTE_COMMIT)
    elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
        $CLI_PATH/sgutil validate $WORKFLOW -h
        exit
    elif [ "$commit_found" = "1" ] && [ "$exists" = "0" ]; then 
        echo ""
        echo "Sorry, the commit ID ${bold}$commit_name${normal} does not exist on the repository."
        echo ""
        exit
    fi
    #header (2/2)
    echo ""
    echo "${bold}sgutil validate $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        $CLI_PATH/sgutil validate coyote -h
        exit
    fi
    #check on acap (temporal until Coyote works on Versal)
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
    if ([ "$device_found" = "1" ] && [[ $device_type = "acap" ]]); then
        echo ""
        echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
        echo ""
        exit
    fi
    #device_dialog (forgotten mandatory 1)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        echo "${bold}Please, choose your device:${normal}"
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        #check on acap (temporal until Coyote works on Versal)
        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
        if [[ $device_type = "acap" ]]; then
            echo ""
            echo "Sorry, this command is not available on ${bold}$device_type!${normal}"
            echo ""
            exit
        fi
        echo ""
    fi
fi

#create commit directory
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name"
if ! [ -d "$DIR" ]; then
    mkdir ${DIR}
fi

#echo ""
#echo "${bold}Please, choose your configuration:${normal}" # this refers to a software (sw/examples) configuration
#echo ""
#PS3=""
#select config in perf_host perf_rdma_host gbm_dtrees
#do
#    case $config in
#        perf_host) break;;
#        perf_rdma_host) break;;
#        gbm_dtrees) break;;
#    esac
#done

#get device_name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#platform to FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#map sw/hw configurations
#case "$config" in
#    perf_host) 
#        config_hw=$config
#        config_sw=$config
#        ;;
#    perf_rdma_host)
#        config_hw=$config
#        config_sw="perf_rdma"
#        ;;
#    gbm_dtrees)
#        config_hw=$config
#        config_sw=$config
#        ;;
#    *)
#        echo ""
#        echo "Unknown config name."
#        echo ""
#    ;;  
#esac

config_hw="static"
config_sw="perf_local"

#set project name
#project_name="validate_$config_hw.$FDEV_NAME.$vivado_version"
project_name="validate_$config_sw.$FDEV_NAME.$vivado_version"

#define directories (1)
DIR="$DIR/$project_name"
SHELL_BUILD_DIR="$DIR/examples_hw/apps/build"           # 06.03.2024 ===> added /apps and does not work... something else is missing
DRIVER_DIR="$DIR/driver"
APP_BUILD_DIR="$DIR/examples_sw/apps/$config_sw/build"  # 05.03.2024 ===> added /apps and works

# create coyote validate config.device_name directory and checkout
if ! [ -d "$DIR" ]; then
    
    #create project path
    mkdir ${DIR}

    #clone Coyote
    $CLI_PATH/common/git_clone_coyote $DIR $commit_name

    #change to project directory
    cd $DIR

    #save COYOTE_COMMIT
    echo "$commit_name" > COYOTE_COMMIT

    #create configuration file (https://github.com/fpgasystems/Coyote/blob/dfx_v2/examples_hw/CMakeLists.txt)
    #touch config_shell_$config_hw
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
        #perf_host) 
        #    echo "const int EN_HLS = 0;" > config_shell.hpp
        #    echo "const int EN_MEM = 0;" >> config_shell.hpp
        #    echo "const int EN_STRM = 1;" >> config_shell.hpp
        #    echo "const int EN_MEM = 0;" >> config_shell.hpp
        #    echo "const int N_REGIONS = 3;" >> config_shell.hpp
        #    ;;
        #perf_fpga)
        #    echo "const int EN_HLS = 0;" > config_shell.hpp
        #    echo "const int EN_BPSS = 1;" >> config_shell.hpp
        #    echo "const int EN_STRM = 1;" >> config_shell.hpp
        #    echo "const int EN_MEM = 0;" >> config_shell.hpp
        #    echo "const int EN_WB = 1;" >> config_shell.hpp
        #    echo "const int N_REGIONS = 1;" >> config_shell.hpp
        #    ;;
        #perf_rdma_host)
        #    echo "const int EN_HLS = 0;" >> config_shell.hpp
        #    echo "const int EN_BPSS = 1;" >> config_shell.hpp
        #    echo "const int EN_STRM = 1;" >> config_shell.hpp
        #    echo "const int EN_MEM = 0;" >> config_shell.hpp
        #    echo "const int EN_RDMA_0 = 1;" >> config_shell.hpp
        #    echo "const int N_REGIONS = 1;" >> config_shell.hpp
        #    ;;
        #gbm_dtrees) 
        #    echo "const int EN_HLS = 0;" > config_shell.hpp
        #    echo "const int EN_STRM = 1;" >> config_shell.hpp
        #    echo "const int EN_MEM = 0;" >> config_shell.hpp
        #    echo "const int N_REGIONS = 1;" >> config_shell.hpp
        #    ;;
        #hyperloglog) 
        #    echo "const int EN_HLS = 1;" > config_shell.hpp
        #    echo "const int EN_STRM = 1;" >> config_shell.hpp
        #    echo "const int EN_MEM = 0;" >> config_shell.hpp
        #    echo "const int N_REGIONS = 1;" >> config_shell.hpp
        #    ;;
        *)
            echo ""
            echo "Unknown configuration."
            echo ""
        ;;  
    esac
    mkdir $DIR/configs
    #mv $DIR/config_shell_$config_hw $DIR/configs/config_shell_$config_hw
    mv $DIR/config_$config_sw $DIR/configs/config_$config_sw
fi

#check on build_dir.FDEV_NAME
if ! [ -e "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit" ]; then
    #bitstream compilation
    echo ""
    echo "${bold}Coyote $config_hw shell compilation:${normal}"
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
    
    #copy bitstream
    cp $SHELL_BUILD_DIR/bitstreams/cyt_top.bit $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.bit
    cp $SHELL_BUILD_DIR/bitstreams/cyt_top.ltx $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/${BIT_NAME%.bit}.$FDEV_NAME.$vivado_version.ltx
        
    #remove all other build temporal folders
    rm -rf $SHELL_BUILD_DIR
    
else
    echo ""
    echo "${bold}Coyote $config_hw shell compilation:${normal}"
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
#rm -rf $DRIVER_DIR/eci
#rm -rf $DRIVER_DIR/pci
    
#compilation happens everytime
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

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$commit_name

#program coyote
sgutil program coyote --commit $commit_name --project $project_name --device $device_index --remote 0
    
#get bus and device
#bus=$($CLI_PATH/program/get_bus_device $device_index bus)
#device=$($CLI_PATH/program/get_bus_device $device_index device)

#run coyote
cd $DIR/build_dir.$config_sw/

echo "${bold}Running perf_local host (./main -t 1 -d $device_index):${normal}"
./main -t 1 -d $device_index #-b $bus -s $device

echo ""
echo "${bold}Running perf_local HBM (./main -t 0 -d $device_index):${normal}"
./main -t 0 -d $device_index #-b $bus -s $device

echo ""

##remote programming (for perf_rdma_host) and run application
#if [ "$config_hw" = "perf_rdma_host" ]; then
#    #program
#    sgutil program coyote --project $project_name --device $device_index --remote 1
#
#    #get local CPU IP address
#    IP_address_cpu1=$($CLI_PATH/get/ifconfig | awk '$1 == "0:" {print $2}')
#    IP_address_cpu1_hex=$($CLI_PATH/common/address_to_hex IP $IP_address_cpu1)
#
#    echo "For finishing your ${bold}perf_rdma_host${normal} Coyote validation:"
#    echo ""
#    echo "    1. Open a new window terminal for ${bold}$servers_family_list${normal}"
#    echo "    2. From such a terminal, run: ${bold}$DIR/build_dir.$FDEV_NAME.$vivado_version/main -t $IP_address_cpu1${normal}"
#    echo "    3. Check your results on this terminal ${bold}($hostname)${normal}"
#    echo ""
#    
#    #run (local CPU)
#    cd $DIR/build_dir.$FDEV_NAME.$vivado_version
#    ./main
#
#else
#    #program
#    sgutil program coyote --project $project_name --device $device_index --remote 0
#    
#    #run
#    cd $DIR/build_dir.$FDEV_NAME.$vivado_version
#    ./main
#fi
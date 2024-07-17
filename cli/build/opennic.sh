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
BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
NUM_JOBS="16"
WORKFLOW="opennic"

#cleanup bitstreams folder
if [ -e "$BITSTREAMS_PATH/foo" ]; then
    sudo $CLI_PATH/common/rm "$BITSTREAMS_PATH/foo"
fi

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"
SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
DRIVER_DIR="$DIR/open-nic-driver"

#platform_name to FDEV_NAME
FDEV_NAME=$(echo "$platform_name" | cut -d'_' -f2)

#define shells
library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#check on shell
compile="0"
if [ ! -e "$project_shell" ]; then
    compile="1"
elif [ -e "$project_shell" ] && [ "$project_name" != "validate_opennic.$commit_name_driver.$FDEV_NAME.$vivado_version" ]; then
    echo "${bold}The shell ${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit already exists. Do you want to remove it and compile it again (y/n)?${normal}"
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
    if [ -f "$DIR/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BITSTREAM_NAME" ]; then
        #copy to project
        cp "$DIR/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BITSTREAM_NAME" "$project_shell"
        #print message
        echo "${bold}${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit is done!${normal}"
        echo ""
        #send email
        user_email=$USER@ethz.ch
        echo "Subject: Good news! sgutil build opennic (${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit) is done!" | sendmail $user_email
    fi
fi

#compile driver
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
rm $DRIVER_DIR/$DRIVER_NAME
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

#author: https://github.com/jmoya82
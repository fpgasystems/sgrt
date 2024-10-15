#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil build aved --project $project_name --tag                            $tag_name --version $vivado_version --all $all 
#example: /opt/sgrt/cli/sgutil build aved --project   hello_world --tag amd_v80_gen5x8_23.2_exdes_2_20240408 --version          2022.2 --all    1 

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
project_name=$2
tag_name=$4
vivado_version=$6
all=$8

#all inputs must be provided
if [ "$project_name" = "" ] || [ "$tag_name" = "" ] || [ "$vivado_version" = "" ] || [ "$all" = "" ]; then
    exit
fi

#constants
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="aved"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"
DIR_PACKAGE="$DIR/sw/AMI/output"

#get AVED example design name (amd_v80_gen5x8_23.2_exdes_2)
aved_name=$(echo "$AVED_TAG" | sed 's/_[^_]*$//')

#define PDI (Programmable Device Images) and XSA names (i.e., amd_v80_gen5x8_23.2_exdes_2_nofpt.pdi and amd_v80_gen5x8_23.2_exdes_2.xsa)
pdi_name="${aved_name}_nofpt.pdi"
xsa_name="${aved_name}.xsa"

#bitstream compilation is only allowed on CPU (build) servers
if [ "$all" = "1" ]; then
    #check on bitstream configuration
    are_equals="0"
    #if [ -f "$DIR/.device_config" ]; then
    #    are_equals=$($CLI_PATH/common/compare_files "$DIR/configs/device_config" "$DIR/.device_config")
    #fi

    compile="0"
    if [ ! -e "$DIR/$pdi_name" ]; then
        compile="1"
    elif [ -e "$DIR/$pdi_name" ] && [ "$are_equals" = "0" ] && [ "$project_name" != "validate_aved.$hostname.$tag_name.$vivado_version" ]; then
        #echo ""
        echo "The Programmable Device Image ${bold}$pdi_name${normal} already exists. Do you want to remove it and compile it again (y/n)?"
        while true; do
            read -p "" yn
            case $yn in
                "y")
                    rm -f $DIR/$pdi_name 
                    rm -rf $DIR/hw/$aved_name/build 
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

    #launch vivado
    if [ "$compile" = "1" ]; then 
        #PDI compilation
        #echo "${bold}PDI compilation (tag ID: $tag_name)${normal}"
        echo "${bold}Programmable Device Image (PDI) compilation${normal}"
        echo ""

        #read configuration
        #tcl_args=$($CLI_PATH/common/get_tclargs $DIR/configs/device_config)
        
        #echo "vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1 $tcl_args"
        #cd $SHELL_BUILD_DIR
        #vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1 $tcl_args
        #echo ""

        #build hardware
        cd $DIR/hw/$aved_name
        ./build_all.sh

        #copy to project folder
        if [ -f "$DIR/hw/$aved_name/build/$pdi_name" ]; then

            echo "I am here 4"

            #pdi and xsa
            cp "$DIR/hw/$aved_name/build/$pdi_name" "$DIR/$pdi_name"
            cp "$DIR/hw/$aved_name/build/$xsa_name" "$DIR/$xsa_name"

            #.device_config
            #cp $DIR/configs/device_config $DIR/.device_config
            #chmod a-w "$DIR/.device_config"

            #print message
            echo "${bold}$pdi_name is done!${normal}"
            echo ""
        fi
    fi
fi

#cleanup timestamp folders (we only want the one that will be generated)
rm -r $DIR_PACKAGE/*/

#compile driver
echo "${bold}Package (driver and application) generation:${normal}"
echo ""
echo "cd $DIR/sw/AMI"
echo "python3 scripts/gen_package.py"
#echo ""

#create package
cd $DIR/sw/AMI
python3 scripts/gen_package.py

#get current timestamp
timestamp=$(basename "$DIR/sw/AMI/output"/*/)

#copy .deb to project folder
cp $DIR_PACKAGE/$timestamp/ami_*.deb $DIR
#echo "cp $DIR_PACKAGE/$timestamp/ami_*.deb $DIR"

#get package_name
package_name=$(basename "$DIR"/ami_*.deb)

echo "The package ${bold}$package_name${normal} was generated!"
echo ""

#application compilation
#echo "${bold}Application compilation:${normal}"
#echo ""
#echo "cd $DIR"
#echo "make"
#echo ""
#cd $DIR
#make

#copy driver
#cp -f $DRIVER_DIR/$DRIVER_NAME $DIR/$DRIVER_NAME

#remove drivier files (generated while compilation)
#rm $DRIVER_DIR/Module.symvers
#rm -rf $DRIVER_DIR/hwmon
#rm $DRIVER_DIR/modules.order
#rm $DRIVER_DIR/$DRIVER_NAME
#rm $DRIVER_DIR/onic.mod
#rm $DRIVER_DIR/onic.mod.c
#rm $DRIVER_DIR/onic.mod.o
#rm $DRIVER_DIR/onic.o
#rm $DRIVER_DIR/onic_common.o
#rm $DRIVER_DIR/onic_ethtool.o
#rm $DRIVER_DIR/onic_hardware.o
#rm $DRIVER_DIR/onic_lib.o
#rm $DRIVER_DIR/onic_main.o
#rm $DRIVER_DIR/onic_netdev.o
#rm $DRIVER_DIR/onic_sysfs.o

#author: https://github.com/jmoya82
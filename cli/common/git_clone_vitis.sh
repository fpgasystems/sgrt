#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
VITIS_DIR=$1
VITIS_COMMIT=$2

#prepare for wget (1)
if [ -d "$VITIS_DIR/common" ]; then
    rm -rf "$VITIS_DIR/common"
fi

#prepare for wget (2)
if [ -d "$VITIS_DIR/tmp" ]; then
    rm -rf "$VITIS_DIR/tmp"
fi

#copy files
#echo ""
echo "${bold}Checking out Vitis_Accel_Examples/common (commit: $VITIS_COMMIT):${normal}"
echo ""
#wget https://github.com/Xilinx/Vitis_Accel_Examples/archive/master.zip -O $VITIS_DIR/master.zip
#mkdir $VITIS_DIR/tmp
#unzip -q $VITIS_DIR/master.zip -d $VITIS_DIR/tmp
#mv -f $VITIS_DIR/tmp/Vitis_Accel_Examples-main/common $VITIS_DIR
#rm -rf $VITIS_DIR/tmp
#rm $VITIS_DIR/master.zip


# Download the repository zip file for the specific commit
wget https://github.com/Xilinx/Vitis_Accel_Examples/archive/$VITIS_COMMIT.zip -O $VITIS_DIR/master.zip

# Create a temporary directory
mkdir "$VITIS_DIR/tmp"

# Unzip the downloaded file to the temporary directory
unzip -q "$VITIS_DIR/master.zip" -d "$VITIS_DIR/tmp"

# Find the directory that matches the pattern Vitis_Accel_Examples-*
EXAMPLES_DIR=$(find "$VITIS_DIR/tmp" -maxdepth 1 -type d -name "Vitis_Accel_Examples-*")

# Move the common directory to the desired location
mv -f "$EXAMPLES_DIR/common" "$VITIS_DIR"

# Remove the temporary directory
rm -rf "$VITIS_DIR/tmp"

# Remove the downloaded zip file
rm "$VITIS_DIR/master.zip"
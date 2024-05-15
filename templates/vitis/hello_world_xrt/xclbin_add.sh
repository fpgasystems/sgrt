#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"

#get template (TEMPLATES_PATH is an environment variable)
XCLBIN_NAME="vadd"
TEMPLATE="$TEMPLATES_PATH/vitis/hello_world_xrt/src/xclbin/$XCLBIN_NAME.cpp" 

# create project
echo ""
echo "${bold}xclbin_add${normal}"
echo ""
echo "${bold}Please, insert a non-existing name for your xclbin:${normal}"
echo ""
while true; do
    read -p "" xclbin_name
    XCLBIN="$MY_PROJECT_PATH/src/xclbin/$xclbin_name.cpp"
    if ! [ -e "$XCLBIN" ]; then
        break
    fi
done
#echo ""

#copy template
cp $TEMPLATE $MY_PROJECT_PATH/src/xclbin/$xclbin_name.cpp

#replace XCLBIN_NAME with $xclbin_name 
sed -i "s/$XCLBIN_NAME/$xclbin_name/g" "$MY_PROJECT_PATH/src/xclbin/$xclbin_name.cpp"

#add to nk
echo "$xclbin_name 1 ${xclbin_name}_a" >> $MY_PROJECT_PATH/nk

echo ""
echo "The XCLBIN ${bold}$xclbin_name${normal} has been added!"
echo ""
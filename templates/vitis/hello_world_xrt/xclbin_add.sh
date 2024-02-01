#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECTS_PATH="$(dirname "$(dirname "$0")")"
TEMPLATE="vadd"
#MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
#WORKFLOW="vitis"
#TEMPLATE_NAME="hello_world_xrt"

# create my_projects directory
#DIR="$MY_PROJECTS_PATH"
#if ! [ -d "$DIR" ]; then
#    mkdir ${DIR}
#fi

# create vitis directory
#VITIS_DIR="$MY_PROJECTS_PATH/$WORKFLOW"
#if ! [ -d "$VITIS_DIR" ]; then
#    mkdir ${VITIS_DIR}
#fi


# create project
echo ""
echo "${bold}xclbin_add${normal}"
echo ""
echo "${bold}Please, insert a non-existing name for your xclbin:${normal}"
echo ""
while true; do
    read -p "" xclbin_name
    #xclbin_name cannot start with validate_
    #if  [[ $xclbin_name == validate_* ]] || [[ $xclbin_name == "test" ]]; then
    #    xclbin_name=""
    #fi
    XCLBIN="$MY_PROJECTS_PATH/src/xclbin/$xclbin_name.cpp"
    if ! [ -e "$XCLBIN" ]; then
        break
    fi
done
#echo ""

#copy template
cp $MY_PROJECTS_PATH/src/xclbin/$TEMPLATE.cpp $MY_PROJECTS_PATH/src/xclbin/$xclbin_name.cpp

echo ""
echo "The XCLBIN ${bold}$xclbin_name${normal} has been added!"
echo ""
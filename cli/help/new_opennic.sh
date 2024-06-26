#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_SHELL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_REPO)

#echo ""
echo "${bold}$CLI_NAME new opennic [flags] [--help]${normal}"
echo ""
echo "Creates a new project using OpenNIC Hello, world! template."
echo ""
echo "FLAGS"
echo "   -c, --commit    - GitHub commit IDs for shell and driver (default: ${bold}$ONIC_SHELL_COMMIT,$ONIC_DRIVER_COMMIT${normal})."
echo "       --project   - Specifies your OpenNIC project name." 
echo "       --push      - Pushes your OpenNIC project to your GitHub account." 
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
#exit 1
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)

#echo ""
echo "${bold}$CLI_NAME new coyote [flags] [--help]${normal}"
echo ""
echo "Creates a new project using Coyote Hello, world! template."
echo ""
echo "FLAGS"
echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
echo "       --project   - Specifies your Coyote project name." 
echo "       --push      - Pushes your Coyote project to your GitHub account (see $CLI_NAME set gh)." 
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
#exit 1
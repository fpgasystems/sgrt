#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2

AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)

echo ""
echo "${bold}$CLI_NAME program aved [flags] [--help]${normal}"
echo ""
echo "Programs a self-built AVED project to a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "       ${bold}--project${normal}   - Specifies your OpenNIC project name." 
echo "       ${bold}--push${normal}      - Pushes your OpenNIC project to your GitHub account." 
echo "   ${bold}-t, --tag${normal}       - GitHub tag ID (default: ${bold}$AVED_TAG${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to program a bitstream."
echo ""
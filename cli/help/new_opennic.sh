#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

ONIC_SHELL_COMMIT=$1
ONIC_DRIVER_COMMIT=$2

#echo ""
echo "${bold}sgutil new opennic [flags] [--help]${normal}"
echo ""
echo "Creates a new project using OpenNIC Hello, world! template."
echo ""
echo "FLAGS"
echo "   -c, --commit    - GitHub commit IDs for shell and driver (default: ${bold}$ONIC_SHELL_COMMIT,$ONIC_DRIVER_COMMIT${normal})."
echo "       --project   - Specifies your OpenNIC project name." 
echo "       --push      - Pushes your OpenNIC project to your GitHub account (see sgutil set gh)." 
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
#exit 1
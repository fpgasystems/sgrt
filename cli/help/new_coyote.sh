#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

COYOTE_COMMIT=$1

#echo ""
echo "${bold}sgutil new coyote [flags] [--help]${normal}"
echo ""
echo "Creates a new project using Coyote Hello, world! template."
echo ""
echo "FLAGS"
echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
echo "       --project   - Specifies your Coyote project name." 
echo "       --push      - Pushes your Coyote project to your GitHub account (see sgutil set gh)." 
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
#exit 1
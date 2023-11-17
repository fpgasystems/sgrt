#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
#CLI_PATH="$(dirname "$(dirname "$0")")" # CLI_PATH is declared as an environment variable

#print message
echo ""
echo "Please type ${bold}source $CLI_PATH/enable/vitis${normal} to enable your favorite Vitis version"
echo ""
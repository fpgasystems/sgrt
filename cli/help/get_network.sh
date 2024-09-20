#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2

echo ""
echo "${bold}$CLI_NAME get network [flags] [--help]${normal}"
echo ""
echo "Networking information for adaptive devices."
echo ""
echo "FLAGS:"
echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
echo "   -p, --port      - Specifies the port number for the network adapter."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
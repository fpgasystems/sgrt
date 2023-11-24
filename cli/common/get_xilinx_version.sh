#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#get_xilinx_version xbutil /opt/xilinx

tool=$1

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#set to empty
tool_string=""
tool_path=""
tool_version=""

#check on tool (xbutil, vitis, vivado) and get version_flag
case "$tool" in
    "xbutil")
        tool_string="XRT"
        version_flag="--version"
        ;;
    "vitis")
        tool_string="Vitis"
        version_flag="-version"
        ;;
    "vivado")
        tool_string="Vivado"
        version_flag="-version"
        ;;
    *)
        echo ""
        echo "Sorry, $tool is not recognized as a valid Xilinx tool."
        echo ""
        exit 1
        ;;
esac

#get tool path
tool_path=$(which $tool)

echo "$tool_path $version_flag"

exit

#check on tool path
if ! [ -z "$tool_path" ]; then
    #get version
    case "$tool" in
        "xbutil")
            tool_string="XRT"
            ;;
        "vitis")
            tool_string="Vitis"
            ;;
        "vivado")
            tool_string="Vivado"
            ;;
        *)
            echo "Invalid tool: $tool"
            exit 1
            ;;
    esac
fi

#print error message (tool_version is empty)
if [ -z "$tool_version" ]; then
    echo ""
    echo "Please, source a valid $tool_string version for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi
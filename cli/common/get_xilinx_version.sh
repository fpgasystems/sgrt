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

#check on tool (xrt, vitis, vivado) and get version_flag
case "$tool" in
    "xrt")
        tool_string="XRT"
        ;;
    "vitis")
        tool_string="Vitis"
        ;;
    "vivado")
        tool_string="Vivado"
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

#check on tool path
if ! [ -z "$tool_path" ]; then
    #get version
    case "$tool" in
        "xrt")
            branch=$(xbutil --version | grep -i -w 'Branch' | tr -d '[:space:]')
            tool_version=${branch:7:6}    
            ;;
        "vitis")
            tool_version=$(vitis -version 2>&1 | grep "Vitis" | awk '{print $3}')
            ;;
        "vivado")
            tool_version=$(vivado -version 2>&1 | grep "Vivado" | awk '{print $3}')
            ;;
        *)
            echo "Invalid tool: $tool"
            exit 1
            ;;
    esac
fi

echo ""
echo $tool_version
echo ""

#print error message (tool_version is empty)
if [ -z "$tool_version" ]; then
    echo ""
    echo "Please, source a valid $tool_string version for ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi
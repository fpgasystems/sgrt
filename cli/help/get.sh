#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
parameter=$3
is_acap=$4
is_build=$5
is_fpga=$6
is_gpu=$7
is_vivado_developer=$8

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

if [ "$parameter" = "--help" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get [arguments [flags]] [--help]${normal}"
        echo ""
        echo "Devices and host information."
        echo ""
        echo "ARGUMENTS:"
        echo "   ifconfig        - Host networking information."
        echo "   servers         - List of servers you can use SSH to connect to."
        if [ "$is_vivado_developer" = "1" ]; then
        echo "   syslog          - Gets the systems log with system messages and events generated by the operating system."
        fi
        echo -e "   ${COLOR_ON1}topo${COLOR_OFF}            - Non-uniform memory access (NUMA) server topology."
        if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo -e "   ${COLOR_ON2}bdf${COLOR_OFF}             - Bus Device Function."
        echo "   clock           - Clock Information."
        echo "   memory          - Memory Information."
        echo "   name            - Device names."
        echo "   network         - Networking information."
        echo "   platform        - Platform name."
        echo "   resource        - Resource Availability."
        echo "   serial          - Serial numbers."
        echo "   slr             - Resource Availability and Memory Information per SLR."
        echo "   workflow        - Current workflow."
        fi
        if [ "$is_gpu" = "1" ]; then
        echo "   bus             - GPU PCI Bus IDs."
        fi
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_fpga $is_gpu
        echo ""
    fi
elif [ "$parameter" = "bdf" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get bdf [flags] [--help]${normal}"
        echo ""
        echo "Bus Device Function."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "bus" ]; then
    if [ "$is_gpu" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get bus [flags] [--help]${normal}"
        echo ""
        echo "GPU PCI Bus IDs."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "clock" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get clock [flags] [--help]${normal}"
        echo ""
        echo "Clock Information."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "memory" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get memory [flags] [--help]${normal}"
        echo ""
        echo "Memory Information."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "name" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get name [flags] [--help]${normal}"
        echo ""
        echo "Device names."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "ifconfig" ]; then
    echo ""
    echo "${bold}$CLI_NAME get ifconfig [--help]${normal}"
    echo ""
    echo "Host networking information."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
elif [ "$parameter" = "platform" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get platform [flags] [--help]${normal}"
        echo ""
        echo "Platform names."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "resource" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get resource [flags] [--help]${normal}"
        echo ""
        echo "Resource Availability."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "serial" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get serial [flags] [--help]${normal}"
        echo ""
        echo "Serial numbers."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "slr" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then  
        echo ""
        echo "${bold}$CLI_NAME get slr [flags] [--help]${normal}"
        echo ""
        echo "Resource Availability and Memory Information per SLR."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "servers" ]; then
    echo ""
    echo "${bold}$CLI_NAME get servers [--help]${normal}"
    echo ""
    echo "List of servers you can use SSH to connect to."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
elif [ "$parameter" = "syslog" ]; then
    echo ""
    echo "${bold}$CLI_NAME get syslog [--help]${normal}"
    echo ""
    echo "Gets the systems log with system messages and events generated by the operating system."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
elif [ "$parameter" = "workflow" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then  
        echo ""
        echo "${bold}$CLI_NAME get workflow [flags] [--help]${normal}"
        echo ""
        echo "Current workflow."
        echo ""
        echo "FLAGS:"
        echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
        echo ""
        echo "   -h, --help      - Help to use this command."
        echo ""
    fi
fi
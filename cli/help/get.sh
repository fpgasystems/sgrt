#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
parameter=$3
is_acap=$4
is_asoc=$5
is_build=$6
is_fpga=$7
is_gpu=$8
is_vivado_developer=$9

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

if [ "$parameter" = "--help" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get [arguments [flags]] [--help]${normal}"
        echo ""
        echo "Devices and host information."
        echo ""
        echo "ARGUMENTS:"
        echo "   ${bold}ifconfig${normal}        - Host networking information."
        echo "   ${bold}servers${normal}         - List of servers you can use SSH to connect to."
        if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
        echo "   ${bold}syslog${normal}          - Gets the systems log with system messages and events generated by the operating system."
        fi
        echo "   ${bold}topo${normal}            - Non-uniform memory access (NUMA) server topology."
        if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON2}bdf${COLOR_OFF}${normal}             - Bus Device Function."
        echo -e "   ${bold}${COLOR_ON2}clock${COLOR_OFF}${normal}           - Clock Information."
        echo -e "   ${bold}${COLOR_ON2}memory${COLOR_OFF}${normal}          - Memory Information."
        echo -e "   ${bold}${COLOR_ON2}name${COLOR_OFF}${normal}            - Device names."
        echo -e "   ${bold}${COLOR_ON2}network${COLOR_OFF}${normal}         - Networking information."
        echo -e "   ${bold}${COLOR_ON2}platform${COLOR_OFF}${normal}        - Platform name."
        echo -e "   ${bold}${COLOR_ON2}resource${COLOR_OFF}${normal}        - Resource Availability."
        echo -e "   ${bold}${COLOR_ON2}serial${COLOR_OFF}${normal}          - Serial numbers."
        echo -e "   ${bold}${COLOR_ON2}slr${COLOR_OFF}${normal}             - Resource Availability and Memory Information per SLR."
        echo -e "   ${bold}${COLOR_ON2}workflow${COLOR_OFF}${normal}        - Current workflow."
        elif [ "$is_asoc" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON2}bdf${COLOR_OFF}${normal}             - Bus Device Function."
        echo -e "   ${bold}${COLOR_ON2}name${COLOR_OFF}${normal}            - Device names."
        echo -e "   ${bold}${COLOR_ON2}network${COLOR_OFF}${normal}         - Networking information."
        echo -e "   ${bold}${COLOR_ON2}partitions${COLOR_OFF}${normal}      - Device partitions."
        echo -e "   ${bold}${COLOR_ON2}serial${COLOR_OFF}${normal}          - Serial numbers."
        echo -e "   ${bold}${COLOR_ON2}workflow${COLOR_OFF}${normal}        - Current workflow."
        fi
        if [ "$is_gpu" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON5}bus${COLOR_OFF}${normal}             - Peripheral Component Interconnect (PCI) identifiers."
        fi
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga $is_gpu
        echo ""
    fi
elif [ "$parameter" = "bdf" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get bdf [flags] [--help]${normal}"
        echo ""
        echo "Bus Device Function."
        echo ""
        echo "FLAGS:"
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
        echo ""
    fi
elif [ "$parameter" = "bus" ]; then
    if [ "$is_gpu" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get bus [flags] [--help]${normal}"
        echo ""
        echo "Peripheral Component Interconnect (PCI) identifiers."
        echo ""
        echo "FLAGS:"
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
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
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
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
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
        echo ""
    fi
elif [ "$parameter" = "name" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get name [flags] [--help]${normal}"
        echo ""
        echo "Device names."
        echo ""
        echo "FLAGS:"
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
        echo ""
    fi
elif [ "$parameter" = "ifconfig" ]; then
    echo ""
    echo "${bold}$CLI_NAME get ifconfig [flags] [--help]${normal}"
    echo ""
    echo "Host networking information."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
    echo "   ${bold}-p, --port${normal}      - Specifies the port number for the network adapter."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
elif [ "$parameter" = "partitions" ]; then
    if [ "$is_asoc" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME get partitions [flags] [--help]${normal}"
            echo ""
            echo "Device partitions."
            echo ""
            echo "FLAGS:"
            echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
            echo "   ${bold}-t, --type${normal}      - Boot device type (primary or secondary)."
            echo ""
            echo "   ${bold}-h, --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
            echo ""
    fi
elif [ "$parameter" = "platform" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get platform [flags] [--help]${normal}"
        echo ""
        echo "Platform names."
        echo ""
        echo "FLAGS:"
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
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
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
        echo ""
    fi
elif [ "$parameter" = "serial" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get serial [flags] [--help]${normal}"
        echo ""
        echo "Serial numbers."
        echo ""
        echo "FLAGS:"
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
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
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
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
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
elif [ "$parameter" = "syslog" ]; then
    if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get syslog [--help]${normal}"
        echo ""
        echo "Gets the systems log with system messages and events generated by the operating system."
        echo ""
        echo "FLAGS:"
        echo "   This command has no flags."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
    fi
elif [ "$parameter" = "workflow" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME get workflow [flags] [--help]${normal}"
        echo ""
        echo "Current workflow."
        echo ""
        echo "FLAGS:"
        echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
        echo ""
    fi
fi
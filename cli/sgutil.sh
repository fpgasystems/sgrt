#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH=$(dirname "$0")
SGRT_PATH=$(dirname "$CLI_PATH")
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"

XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#inputs
command=$1
arguments=$2

cli_help() {
  cli_name=${0##*/}
  echo "
${bold}$cli_name [commands] [arguments [flags]] [--help] [--version]${normal}

COMMANDS:
   build           - Creates binaries, bitstreams, and drivers for your accelerated applications.
   enable          - Enables your favorite development and deployment tools.
   examine         - Status of the system and devices.
   get             - Devices and host information.
   new             - Creates a new project of your choice.
   program         - Download the acceleration program to a given FPGA/ACAP.
   reboot          - Reboots the server (warm boot).
   run             - Executes the accelerated application on a given device.
   set             - Devices and host configuration.
   validate        - Validates the basic HACC infrastructure functionality.

   -h, --help      - Help to use this application.
   -v, --version   - Reports CLI version.
"
  exit 1
}

cli_version() {
    version=$(cat $SGRT_PATH/VERSION)
    echo ""
    echo "Version              : $version"
    echo ""
    exit 1
}

command_run() {
    
    # we use an @ to separate between command_arguments_flags and the valid_flags
    read input <<< $@
    aux_1="${input%%@*}"
    aux_2="${input##$aux_1@}"

    read -a command_arguments_flags <<< "$aux_1"
    read -a valid_flags <<< "$aux_2"

    START=2
    if [ "${command_arguments_flags[$START]}" = "-h" ] || [ "${command_arguments_flags[$START]}" = "--help" ]; then
      ${command_arguments_flags[0]}_${command_arguments_flags[1]}_help # i.e., validate_iperf_help
    else
      flags=""
      j=0
      for (( i=$START; i<${#command_arguments_flags[@]}; i++ ))
      do
	      if [[ " ${valid_flags[*]} " =~ " ${command_arguments_flags[$i]} " ]]; then
	        flags+="${command_arguments_flags[$i]} "
	        i=$(($i+1))
	        flags+="${command_arguments_flags[$i]} "
	      else
          ${command_arguments_flags[0]}_${command_arguments_flags[1]}_help # i.e., validate_iperf_help
	      fi
      done

      $CLI_PATH/${command_arguments_flags[0]}/${command_arguments_flags[1]} $flags

    fi
}

check_on_flags() {
    
    # we use an @ to separate between command_arguments_flags and the valid_flags
    read input <<< $@
    aux_1="${input%%@*}"
    aux_2="${input##$aux_1@}"

    read -a command_arguments_flags <<< "$aux_1"
    read -a valid_flags <<< "$aux_2"

    START=2
    if [ "${command_arguments_flags[$START]}" = "-h" ] || [ "${command_arguments_flags[$START]}" = "--help" ]; then
      ${command_arguments_flags[0]}_${command_arguments_flags[1]}_help # i.e., validate_iperf_help
    else
      flags=""
      j=0
      for (( i=$START; i<${#command_arguments_flags[@]}; i++ ))
      do
	      if [[ " ${valid_flags[*]} " =~ " ${command_arguments_flags[$i]} " ]]; then
	        flags+="${command_arguments_flags[$i]} "
	        i=$(($i+1))
	        flags+="${command_arguments_flags[$i]} "
	      else
          ${command_arguments_flags[0]}_${command_arguments_flags[1]}_help # i.e., validate_iperf_help
          #echo "-1"
          #break
	      fi
      done
    fi
}

check_on_vivado() {
  local VIVADO_PATH=$1
  local hostname=$2
  local vivado_version=$3
  if [ ! -d $VIVADO_PATH/$vivado_version ]; then
    echo ""
    echo "Please, choose a valid Vivado version for ${bold}$hostname!${normal}"
    echo ""
    exit 1
  fi
}

check_on_fpga() {
  local CLI_PATH=$1
  local hostname=$2
  acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
      echo ""
      echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
      echo ""
      exit 1
  fi
}

check_on_virtualized() {
  local CLI_PATH=$1
  local hostname=$2
  virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
  if [ "$virtualized" = "1" ]; then
      echo ""
      echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
      echo ""
      exit
  fi
}

# build ------------------------------------------------------------------------------------------------------------------------

build_help() {
    echo ""
    echo "${bold}sgutil build [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Creates binaries, bitstreams, and drivers for your accelerated applications."
    echo ""
    echo "ARGUMENTS:"
    echo "   coyote          - Generates Coyote's bitstreams and drivers."
    echo "   hip             - Generates HIP binaries for your projects."
    echo "   mpi             - Generates MPI binaries for your projects."
    echo "   opennic         - Generates OpenNIC's bitstreams and drivers."
    echo "   vitis           - Uses acap_fpga_xclbin to generate XCLBIN binaries for Vitis workflow." #Vitis .xo kernels and .xclbin binaries generation.
    #echo "   vivado (soon)   - Generates .bit bitstreams and .ko drivers for Vivado workflow." #Compiles a bitstream and a driver.
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

build_coyote_help() {
    echo ""
    echo "${bold}sgutil build coyote [flags] [--help]${normal}"
    echo ""
    echo "Generates Coyote's bitstreams and drivers."
    echo ""
    echo "FLAGS:"
    #echo "   -c, --config    - Coyote's configuration:"
    #echo "                         perf_hosts, perf_fpga, gbm_dtrees,"
    #echo "                         hyperloglog, perf_dram, perf_hbm,"
    #echo "                         perf_rdma_host, perf_rdma_card, perf_tcp,"
    #echo "                         rdma_regex, service_aes, service_reconfiguration."
    #echo "   -n, --name      - FPGA's device name. See sgutil get name."
    echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
    echo "       --platform  - Xilinx platform (according to sgutil get platform)."
    echo "       --project   - Specifies your Coyote project name."
    echo ""
    echo "   -h, --help      - Help to build Coyote."
    echo ""
    exit 1
}

build_hip_help() {
    echo ""
    echo "${bold}sgutil build hip [flags] [--help]${normal}"
    echo ""
    echo "Generates HIP binaries for your projects."
    echo ""
    echo "FLAGS:"
    echo "   -p, --project   - Specifies your HIP project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

build_mpi_help() {
    echo ""
    echo "${bold}sgutil build mpi [flags] [--help]${normal}"
    echo ""
    echo "Generates MPI binaries for your projects."
    echo ""
    echo "FLAGS:"
    #echo "   This command has no flags."
    echo "   -p, --project   - Specifies your MPI project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

build_opennic_help() {
    $CLI_PATH/help/build_opennic $ONIC_SHELL_COMMIT
    exit
}

build_vitis_help() {
    echo ""
    echo "${bold}sgutil build vitis [flags] [--help]${normal}"
    echo ""
    echo "Uses acap_fpga_xclbin to generate XCLBIN binaries for Vitis workflow."
    echo ""
    echo "FLAGS:"
    #echo "       --platform  - Xilinx platform (according to sgutil get platform)."
    echo "   -p, --project   - Specifies your Vitis project name."
    echo "   -t, --target    - Binary compilation target (host, sw_emu, hw_emu, hw)."
    #echo "   -x, --xclbin    - The name of the XCLBIN to be compiled."
    echo ""
    echo "   -h, --help      - Help to build a binary."
    echo ""
    exit 1
}

build_vivado_help() {
    echo ""
    echo "${bold}sgutil build vivado [flags] [--help]${normal}"
    echo ""
    echo "Generates .bit bitstreams and .ko drivers for Vivado workflow."
    echo ""
    echo "FLAGS:"
    #echo "   -p, --project   - Specifies your Vivado project name."
    echo ""
    echo "   -h, --help      - Help to build a bitstream."
    echo ""
    exit 1
}

#enable
enable_help() {
    echo ""
    echo "${bold}sgutil enable [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Enables your favorite development and deployment tools on your server."
    echo ""
    echo "ARGUMENTS:"
    echo "   vitis           - Enables Vitis SDK (Software Development Kit) and Vitis_HLS (High-Level Synthesis)."
    echo "   vivado          - Enables Vivado HDI (Hardware Design and Implementation)."
    echo "   xrt             - Enables Xilinx Runtime (XRT)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

enable_vitis_help() {
    echo ""
    echo "${bold}sgutil enable vitis [--help]${normal}"
    echo ""
    echo "Enables Vitis SDK (Software Development Kit) and Vitis_HLS (High-Level Synthesis)."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

enable_vivado_help() {
    echo ""
    echo "${bold}sgutil enable vivado [--help]${normal}"
    echo ""
    echo "Enables Vivado HDI (Hardware Design and Implementation)."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

enable_xrt_help() {
    echo ""
    echo "${bold}sgutil enable xrt [--help]${normal}"
    echo ""
    echo "Enables Xilinx Runtime (XRT)."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

# examine ------------------------------------------------------------------------------------------------------------------------

examine_help() {
    echo ""
    echo "${bold}sgutil examine [--help]${normal}"
    echo ""
    echo "Status of the system and devices."
    echo ""
    echo "ARGUMENTS"
    echo "   This command has no arguments."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}


# get ----------------------------------------------------------------------------------------------------------------------------

get_help() {
    echo ""
    echo "${bold}sgutil get [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Devices and host information."
    echo ""
    echo "ARGUMENTS:"
    echo "   ifconfig        - Retreives host networking information."
    echo "   servers         - Retreives the list of servers you can use SSH to connect to."
    echo "   syslog          - Gets the systems log with system messages and events generated by the operating system."
    echo ""
    echo "   bdf             - Retreives FPGA/ACAP Bus Device Function."
    echo "   clock           - Retreives FPGA/ACAP Clock Information."
    echo "   memory          - Retreives FPGA/ACAP Memory Information."
    echo "   name            - Retreives FPGA/ACAP device names."
    echo "   network         - Retreives FPGA/ACAP networking information."
    echo "   platform        - Retreives FPGA/ACAP platform name."
    echo "   resource        - Retreives FPGA/ACAP Resource Availability."
    echo "   serial          - Retreives FPGA/ACAP serial numbers."
    echo "   slr             - Retreives FPGA/ACAP Resource Availability and Memory Information per SLR."
    echo "   workflow        - Retreives FPGA/ACAP current workflow."
    echo ""
    echo "   bus             - Retreives GPU PCI Bus ID."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_bdf_help() {
    echo ""
    echo "${bold}sgutil get bdf [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Bus Device Function."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_clock_help() {
    echo ""
    echo "${bold}sgutil get clock [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Clock Information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_bus_help() {
    echo ""
    echo "${bold}sgutil get bus [flags] [--help]${normal}"
    echo ""
    echo "Retreives GPU PCI Bus ID."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - GPU Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_memory_help() {
    echo ""
    echo "${bold}sgutil get clock [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Memory Information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_name_help() {
    echo ""
    echo "${bold}sgutil get name [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP device names."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_ifconfig_help() {
    echo ""
    echo "${bold}sgutil get ifconfig [--help]${normal}"
    echo ""
    echo "Retreives host networking information."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_network_help() {
    echo ""
    echo "${bold}sgutil get network [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP networking information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_platform_help() {
    echo ""
    echo "${bold}sgutil get platform [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP platform names."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_resource_help() {
    echo ""
    echo "${bold}sgutil get resource [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Resource Availability."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_serial_help() {
    echo ""
    echo "${bold}sgutil get serial [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP serial numbers."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_slr_help() {
    echo ""
    echo "${bold}sgutil get slr [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Retreives FPGA/ACAP Resource Availability and Memory Information per SLR."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_syslog_help() {
    echo ""
    echo "${bold}sgutil get syslog [--help]${normal}"
    echo ""
    echo "Gets the systems log with system messages and events generated by the operating system."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_workflow_help() {
    echo ""
    echo "${bold}sgutil get workflow [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP current workflow."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_servers_help() {
    echo ""
    echo "${bold}sgutil get servers [--help]${normal}"
    echo ""
    echo "Retreives the list of servers you can use SSH to connect to."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

# new ------------------------------------------------------------------------------------------------------------------------

new_help() {
    echo ""
    echo "${bold}sgutil new [arguments] [--help]${normal}"
    echo ""
    echo "Creates a new project of your choice."
    echo ""
    echo "ARGUMENTS:"
    echo "   coyote          - Creates a new project using Coyote Hello, world! template."
    echo "   hip             - Creates a new project using HIP Hello, world! template."
    echo "   mpi             - Creates a new project using MPI Hello, world! template."
    echo "   opennic         - Creates a new project using OpenNIC Hello, world! template."
    echo "   vitis           - Creates a new project using Vitis Hello, world! template." 
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

new_coyote_help() {
    $CLI_PATH/help/new_coyote $COYOTE_COMMIT
    exit
}

new_hpi_help() {
    echo ""
    echo "${bold}sgutil new hip [--help]${normal}"
    echo ""
    echo "Creates a new project using HIP Hello, world! template."
    echo ""
    echo "FLAGS"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

new_mpi_help() {
    echo ""
    echo "${bold}sgutil new mpi [--help]${normal}"
    echo ""
    echo "Creates a new project using MPI Hello, world! template."
    echo ""
    echo "FLAGS"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

new_opennic_help() {
    $CLI_PATH/help/new_opennic $ONIC_SHELL_COMMIT $ONIC_DRIVER_COMMIT
    exit
}

new_vitis_help() {
    echo ""
    echo "${bold}sgutil new vitis [--help]${normal}"
    echo ""
    echo "Creates a new project using Vitis Hello, world! template."
    echo ""
    echo "FLAGS"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

# program ------------------------------------------------------------------------------------------------------------------------

program_help() {
    echo ""
    echo "${bold}sgutil program [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Download the acceleration program to a given FPGA/ACAP."
    echo ""
    echo "ARGUMENTS:"
    echo "   coyote          - Programs Coyote to a given FPGA."
    echo "   driver          - Inserts a driver or module into the Linux kernel."
    echo "   opennic         - Programs OpenNIC to a given FPGA."
    echo "   reset           - Resets a given FPGA/ACAP."
    echo "   revert          - Returns the specified FPGA to the Vitis workflow."
    echo "   vitis           - Programs a Vitis binary to a given FPGA/ACAP."
    echo "   vivado          - Programs a Vivado bitstream to a given FPGA."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

program_coyote_help() {
    echo ""
    echo "${bold}sgutil program coyote [flags] [--help]${normal}"
    echo ""
    echo "Programs Coyote to a given FPGA."
    echo ""
    echo "FLAGS:"
    echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
    echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
    echo "   -p, --project   - Specifies your Coyote project name." 
    #echo "       --regions   - Sets the number of independent regions (vFPGA)."
    echo "       --remote    - Local or remote deployment."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

program_driver_help() {
    echo ""
    echo "${bold}sgutil program driver [flags] [--help]${normal}"
    echo ""
    echo "Inserts a driver or module into the Linux kernel."
    echo ""
    echo "FLAGS:"
    echo "   -m, --module    - Full path to the .ko module to be inserted."
    echo "   -p, --params    - A comma separated list of module parameters." 
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

program_opennic_help() {
    echo ""
    echo "${bold}sgutil program opennic [flags] [--help]${normal}"
    echo ""
    echo "Programs OpenNIC to a given FPGA."
    echo ""
    echo "FLAGS:"
    echo "   -c, --commit    - GitHub commit ID (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
    echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
    echo "   -p, --project   - Specifies your OpenNIC project name." 
    #echo "       --regions   - Sets the number of independent regions (vFPGA)."
    echo "       --remote    - Local or remote deployment."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

program_reset_help() {
    echo ""
    echo "${bold}sgutil program reset [flags] [--help]${normal}"
    echo ""
    echo "Resets a given FPGA/ACAP."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

program_revert_help() {
    $CLI_PATH/help/program_revert
    exit 
}

program_vivado_help() {
    echo ""
    echo "${bold}sgutil program vivado [flags] [--help]${normal}"
    echo ""
    echo "Programs a Vivado bitstream to a given FPGA."
    echo ""
    echo "FLAGS:"
    echo "   -b, --bitstream - Full path to the .bit bitstream to be programmed." 
    echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
    #echo "       --driver    - Driver (.ko) file path."
    echo ""
    echo "   -h, --help      - Help to program a bitstream."
    echo ""
    exit 1
}

program_vitis_help() {
    echo ""
    echo "${bold}sgutil program vitis [flags] [--help]${normal}"
    echo ""
    echo "Programs a Vitis binary to a given FPGA/ACAP."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
    echo "   -p, --project   - Specifies your Vitis project name."
    echo "   -r, --remote    - Local or remote deployment."
    echo "   -x, --xclbin    - Vitis binary name to be programmed on the device."
    echo ""
    echo "   -h, --help      - Help to program a binary."
    echo ""
    exit 1
}

# reboot -------------------------------------------------------------------------------------------------------

reboot_help() {
    echo ""
    echo "${bold}sgutil reboot [--help]${normal}"
    echo ""
    echo "Reboots the server (warm boot)."
    echo ""
    echo "ARGUMENTS:"
    echo "   This command has no arguments."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

# run ------------------------------------------------------------------------------------------------------------------------

run_help() {
    echo ""
    echo "${bold}sgutil run [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Executes your accelerated application."
    echo ""
    echo "ARGUMENTS:"
    echo "   mpi             - Runs your MPI application according to your setup."
    echo ""
    echo "   coyote          - Runs Coyote on a given FPGA."
    echo "   vitis           - Runs a Vitis FPGA-binary on a given FPGA/ACAP."
    echo ""
    echo "   hip             - Runs your HIP application on a given GPU."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

run_coyote_help() {
    echo ""
    echo "${bold}sgutil run coyote [flags] [--help]${normal}"
    echo ""
    echo "Runs Coyote on a given FPGA."
    echo ""
    echo "FLAGS:"
    echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
    echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
    echo "   -p, --project   - Specifies your Coyote project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

run_hip_help() {
    echo ""
    echo "${bold}sgutil run hip [flags] [--help]${normal}"
    echo ""
    echo "Runs your HIP application on a given GPU."
    echo ""
    echo "FLAGS"
    echo "   -d, --device    - GPU Device Index (see sgutil examine)."
    echo "   -p, --project   - Specifies your HIP project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

run_mpi_help() {
    echo ""
    echo "${bold}sgutil run mpi [flags] [--help]${normal}"
    echo ""
    echo "Runs your MPI application according to your setup."
    echo ""
    echo "FLAGS"
    echo "   -p, --project   - Specifies your MPI project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

run_vitis_help() {
    echo ""
    echo "${bold}sgutil run vitis [flags] [--help]${normal}"
    echo ""
    echo "Runs a Vitis FPGA-binary on a given FPGA/ACAP."
    echo ""
    echo "FLAGS:"
    #echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
    echo "   -c, --config    - Specifies a configuration of your choice."
    echo "   -p, --project   - Specifies your Vitis project name."
    echo "   -t, --target    - Binary compilation target (sw_emu, hw_emu, hw)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

# set ------------------------------------------------------------------------------------------------------------------------

set_help() {
    echo ""
    echo "${bold}sgutil set [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Devices and host configuration."
    echo ""
    echo "ARGUMENTS:"
    echo "   gh              - Enables GitHub CLI on your host."
    echo "   keys            - Creates your RSA key pairs and adds to authorized_keys and known_hosts."
    echo "   license         - Configures a set of verified license servers for Xilinx tools."
    echo "   mtu             - Sets a valid MTU value to your host networking interface."
    #echo "   write           - Assigns writing permissions on a given device."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

set_gh_help() {
    echo ""
    echo "${bold}sgutil set gh [--help]${normal}"
    echo ""
    echo "Enables GitHub CLI on your host."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

set_keys_help() {
    echo ""
    echo "${bold}sgutil set keys [--help]${normal}"
    echo ""
    echo "Creates your RSA key pairs and adds to authorized_keys and known_hosts."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

set_license_help() {
    echo ""
    echo "${bold}sgutil set license [--help]${normal}"
    echo ""
    echo "Configures a set of verified license servers for Xilinx tools."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

set_mtu_help() {
    echo ""
    echo "${bold}sgutil set mtu [flags] [--help]${normal}"
    echo ""
    echo "Sets a valid MTU value to your host networking interface."
    echo ""
    echo "FLAGS:"
    echo "   -v, --value     - Maximum Transmission Unit (MTU) value (in bytes)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

#set_write_help() {
#      echo ""
#      echo "${bold}sgutil set write [flags] [--help]${normal}"
#      echo ""
#      echo "Assigns writing permissions to a given device."
#      echo ""
#      echo "FLAGS:"
#      echo "   -i, --index     - PCI device index. See sgutil get devices."
#      echo ""
#      echo "   -h, --help      - Help to use this command."
#      echo ""
#      exit 1
#}

# validate -----------------------------------------------------------------------------------------------------------------------
validate_help() {
    echo ""
    echo "${bold}sgutil validate [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Validates the basic HACC infrastructure functionality."
    echo ""
    echo "ARGUMENTS:"
    echo "   docker          - Validates Docker installation on the server."
    echo "   iperf           - Measures HACC network performance."
    echo "   mpi             - Validates MPI."
    echo ""
    echo "   coyote          - Validates Coyote on the selected FPGA/ACAP."
    echo "   opennic         - Validates OpenNIC on the selected FPGA/ACAP."
    echo "   vitis           - Validates Vitis workflow on the selected FPGA/ACAP." 
    echo "   vitis-ai        - Validates Vitis AI workflow on the selected FPGA????????/ACAP." 
    echo ""
    echo "   hip             - Validates HIP on the selected GPU." 
    echo "" 
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

validate_coyote_help() {
      echo ""
      echo "${bold}sgutil validate coyote [flags] [--help]${normal}"
      echo ""
      echo "Validates Coyote on the selected FPGA."
      echo ""
      echo "FLAGS:"
      echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
      echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
      echo ""
      echo "   -h, --help      - Help to use Coyote validation."
      echo ""
      exit 1
}

validate_docker_help() {
      echo ""
      echo "${bold}sgutil validate docker [--help]${normal}"
      echo ""
      echo "Validates Docker installation on the server."
      echo ""
      echo "FLAGS:"
      echo "   This command has no flags."
      echo ""
      echo "   -h, --help      - Help to use this command."
      echo ""
      exit 1
}

validate_hip_help() {
      echo ""
      echo "${bold}sgutil validate hip [flags] [--help]${normal}"
      echo ""
      echo "Validates HIP on the selected GPU."
      echo ""
      echo "FLAGS:"
      echo "   -d, --device    - GPU Device Index (see sgutil examine)."
      echo ""
      echo "   -h, --help      - Help to use HIP validation."
      echo ""
      exit 1
}

validate_iperf_help() {
      echo ""
      echo "${bold}sgutil validate iperf [flags] [--help]${normal}"
      echo ""
      echo "Measures HACC network performance."
      echo ""
      echo "FLAGS:"
      echo "   -b, --bandwidth - Bandwidth to send at in bits/sec or packets per second."
      echo "   -p, --parallel  - Number of parallel client threads to run."
      echo "   -t, --time      - Time in seconds to transmit for."
      echo "   -u, --udp       - When set to 1, uses UDP rather than TCP."
      echo ""
      echo "   -h, --help      - Help to use iperf validation."
      echo ""
      exit 1
}

validate_mpi_help() {
      echo ""
      echo "${bold}sgutil validate mpi [flags] [--help]${normal}"
      echo ""
      echo "Validates MPI."
      echo ""
      echo "FLAGS:"
      echo "   -p, --processes - Specify the number of processes to use."
      echo ""
      echo "   -h, --help      - Help to use MPI validation."
      echo ""
      exit 1
}

validate_opennic_help() {
    $CLI_PATH/help/validate_opennic $ONIC_SHELL_COMMIT $ONIC_DRIVER_COMMIT
    exit
}

validate_vitis_help() {
      echo ""
      echo "${bold}sgutil validate vitis [flags] [--help]${normal}"
      echo ""
      echo "Validates Vitis workflow on the selected FPGA/ACAP."
      echo ""
      echo "FLAGS:"
      echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
      echo ""
      echo "   -h, --help      - Help to use Vitis validation."
      echo ""
      exit 1
}

validate_vitis_ai_help() {
      echo ""
      echo "${bold}sgutil validate vitis-ai [flags] [--help]${normal}"
      echo ""
      echo "Validates Vitis AI workflow on the selected FPGA????????/ACAP."
      echo ""
      echo "FLAGS:"
      echo "   -d, --device    - FPGA Device Index (see sgutil examine)."
      echo ""
      echo "   -h, --help      - Help to use Vitis validation."
      echo ""
      exit 1
}

# read all input parameters (@)
read command_arguments_flags <<< $@ #command$arguments

# ensure -h or --help are going at the beginning
#-h
if [[ $(echo "$command_arguments_flags" | grep "\-h\b" | wc -l) = 1 ]]; then
  #echo "first: $command_arguments_flags"
  #remove -h
  command_arguments_flags=${command_arguments_flags/-h/""}
  #echo "second: $command_arguments_flags"
  #remove command and arguments
  command_arguments_flags=${command_arguments_flags/$command" "/""}
  #echo "third: $command_arguments_flags"
  command_arguments_flags=${command_arguments_flags/$arguments" "/""}
  #echo "fourth: $command_arguments_flags"
  #add it at the beginning
  command_arguments_flags=$command" "$arguments" -h "$command_arguments_flags
  #echo "fifth: $command_arguments_flags"
fi
#--help
if [[ $(echo "$command_arguments_flags" | grep "\-\-help\b" | wc -l) = 1 ]]; then
  #echo "first: $command_arguments_flags"
  #remove --help
  command_arguments_flags=${command_arguments_flags/--help/""}
  #echo "second: $command_arguments_flags"
  #remove command and arguments
  command_arguments_flags=${command_arguments_flags/$command" "/""}
  #echo "third: $command_arguments_flags"
  command_arguments_flags=${command_arguments_flags/$arguments" "/""}
  #echo "fourth: $command_arguments_flags"
  #add it at the beginning
  command_arguments_flags=$command" "$arguments" -h "$command_arguments_flags
  #echo "fifth: $command_arguments_flags"
fi

#get username
username=$USER

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#sgutil
case "$command" in
  -h|--help)
    cli_help
    ;;
  -v|--version)
    cli_version
    ;;
  build)
    case "$arguments" in
      -h|--help)
        build_help
        ;;
      coyote) 
        valid_flags="-c --commit --platform --project -h --help" 
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      hip) 
        valid_flags="-p --project -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      mpi) 
        valid_flags="-p --project -h --help" 
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic) 
        valid_flags="-c --commit --platform --project -h --help" 
        echo ""
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      vitis) 
        valid_flags="-p --project -t --target -h --help" #-x --xclbin 
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      *)
        build_help
      ;;  
    esac
    ;;
  enable)
    case "$arguments" in
      -h|--help)
        enable_help
        ;;
      vitis) 
        if [ "$#" -ne 2 ]; then
          enable_vitis_help
          exit 1
        fi
        eval "$CLI_PATH/enable/vitis-msg"
        ;;
      vivado) 
        if [ "$#" -ne 2 ]; then
          enable_vivado_help
          exit 1
        fi
        eval "$CLI_PATH/enable/vivado-msg"
        ;;
      xrt) 
        if [ "$#" -ne 2 ]; then
          enable_xrt_help
          exit 1
        fi
        eval "$CLI_PATH/enable/xrt-msg"
        ;;
      *)
        enable_help
      ;;  
    esac
    ;;
  examine)
    case "$arguments" in
      -h|--help)
        examine_help
        ;;
      *)
        if [ "$#" -ne 1 ]; then
          examine_help
          exit 1
        fi
        $CLI_PATH/examine
        ;;
    esac
    ;;
  get)
    case "$arguments" in
      -h|--help)
        get_help
        ;;
      bdf)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      clock)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      bus)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      memory)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      name)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      ifconfig)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      network)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      platform)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      resource)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      serial)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      slr)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      servers)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      syslog)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      workflow)
        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      *)
        get_help
      ;;
    esac
    ;;
  new)
    case "$arguments" in
      -h|--help)
        new_help
        ;;
      coyote)
        valid_flags="-c --commit --project --push -h --help"
        echo ""
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      hip)
        if [ "$#" -ne 2 ]; then
          new_hpi_help
          exit 1
        fi
        $CLI_PATH/new/hip
        ;;
      mpi)
        if [ "$#" -ne 2 ]; then
          new_mpi_help
          exit 1
        fi
        $CLI_PATH/new/mpi
        ;;
      opennic)
        valid_flags="-c --commit --project --push -h --help"
        echo ""
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      vitis)
        if [ "$#" -ne 2 ]; then
          new_vitis_help
          exit 1
        fi
        $CLI_PATH/new/vitis
        ;;
      *)
        new_help
      ;;
    esac
    ;;
  program)
    #check on ACAP or FPGA servers (server must have at least one configurable device)
    check_on_fpga "$CLI_PATH" "$hostname"
    
    #get vivado_version
    vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
    
    #check on valid Vivado version
    check_on_vivado "$VIVADO_PATH" "$hostname" "$vivado_version"
    
    #check on DEVICES_LIST
    source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

    #get number of fpga and acap devices present
    MAX_DEVICES=$($CLI_PATH/common/get_max_devices "fpga|acap" $DEVICES_LIST)
    
    #get multiple devices
    multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

    case "$arguments" in
      -h|--help)
        program_help
        ;;
      coyote)
        valid_flags="-c --commit -d --device -p --project --remote -h --help" #--regions
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      driver)
        valid_flags="-m --module -p --params -h --help"
        echo ""
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        valid_flags="-c --commit -d --device -p --project --remote -h --help" #--regions
        echo ""
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      reset) 
        valid_flags="-d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      revert)
        #check on flags
        valid_flags="-d --device -v --version -h --help" # -v --version are not exposed and not shown in help command or completion
        check_on_flags $command_arguments_flags"@"$valid_flags

        #check on virtualized
        check_on_virtualized "$CLI_PATH" "$hostname"

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #print header
        if [[ "$flags_array" = "" ]] && [[ $multiple_devices = "1" ]]; then
            echo ""
            echo "${bold}sgutil program revert${normal}"
            echo ""
        fi

        #check on flags
        device_found=""
        device_index=""
        if [ "$flags_array" = "" ]; then
            #device_dialog
            if [[ $multiple_devices = "0" ]]; then
                device_found="1"
                device_index="1"
            else
                echo "${bold}Please, choose your device:${normal}"
                echo ""
                result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
                device_found=$(echo "$result" | sed -n '1p')
                device_index=$(echo "$result" | sed -n '2p')
            fi
        else
            #device_dialog_check
            result="$("$CLI_PATH/common/device_dialog_check" "${flags_array[@]}")"
            device_found=$(echo "$result" | sed -n '1p')
            device_index=$(echo "$result" | sed -n '2p')
            #forbidden combinations
            if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
                $CLI_PATH/help/program_revert
                exit
            fi
            #device_dialog (forgotten mandatory)
            if [[ $multiple_devices = "0" ]]; then
                device_found="1"
                device_index="1"
            elif [[ $device_found = "0" ]]; then
                $CLI_PATH/help/program_revert
                exit
            fi
        fi

        #add additional echo
        if [[ "$flags_array" = "" ]] && [[ $multiple_devices = "1" ]]; then
            workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
            if [[ $workflow = "vitis" ]]; then
                echo ""
            fi
        fi

        #check on workflow
        workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
        if [[ $workflow = "vitis" ]]; then
            exit
        fi

        echo ""
        $CLI_PATH/program/revert --device $device_index --version $vivado_version

        #valid_flags="-d --device -v --version -h --help" # -v --version are not exposed and not shown in help command or completion
        #command_run $command_arguments_flags"@"$valid_flags
        ;;
      vivado)
        valid_flags="-b --bitstream -d --device -v --version -h --help" # -v --version are not exposed and not shown in help command or completion (Javier: 04.12.2023 --driver)  
        echo ""
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      vitis)
        valid_flags="-d --device -p --project -r --remote -x --xclbin -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      *)
        program_help
      ;;
    esac
    ;;
  reboot)
    case "$arguments" in
      -h|--help)
        reboot_help
        ;;
      *)
        if [ "$#" -ne 1 ]; then
          reboot_help
          exit 1
        fi
        $CLI_PATH/reboot
        ;;
    esac
    ;;
  run)
    case "$arguments" in
      -h|--help)
        run_help
        ;;
      coyote) 
        valid_flags="-c --commit -d --device -p --project -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      hip) 
        valid_flags="-d --device -p --project -h --help" 
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      mpi) 
        valid_flags="-p --project -h --help" 
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      vitis) 
        valid_flags="-c --config -p --project -t --target -h --help" #-d --device 
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      *)
        run_help
      ;;  
    esac
    ;;
  set)
    case "$arguments" in
      -h|--help)
        set_help
        ;;
      gh)
        if [ "$#" -ne 2 ]; then
          set_gh_help
          exit 1
        fi
        eval "$CLI_PATH/set/gh"
        ;;
      keys)
        if [ "$#" -ne 2 ]; then
          set_keys_help
          exit 1
        fi
        eval "$CLI_PATH/set/keys"
        ;;
      license) 
        if [ "$#" -ne 2 ]; then
          set_license_help
          exit 1
        fi
        eval "$CLI_PATH/set/license-msg"
        ;;
      mtu) 
        valid_flags="-v --value -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      #write) 
      #  valid_flags="-i --index -h --help"
      #  command_run $command_arguments_flags"@"$valid_flags
      #  ;;
      *)
        set_help
      ;;  
    esac
    ;;
  validate)
    case "$arguments" in
      coyote)
        valid_flags="-c --commit -d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      docker)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      hip)
        valid_flags="-d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      iperf)
        #valid flags
        valid_flags="-b --bandwidth -h --help -p --parallel -t --time -u --udp"
        
        # ensure -u or --udp are going at the end
        #if [[ $(echo "$command_arguments_flags" | grep "\-u\b" | wc -l) = 1 ]]; then
        #  #remove -u
        #  command_arguments_flags=${command_arguments_flags/-u/""}
        #  #add it at the end
        #  command_arguments_flags=$command_arguments_flags" -u"
        #fi
        #if [[ $(echo "$command_arguments_flags" | grep "\-\-udp\b" | wc -l) = 1 ]]; then
        #  #remove --udp
        #  command_arguments_flags=${command_arguments_flags/--udp/""}
        #  #add it at the end
        #  command_arguments_flags=$command_arguments_flags" -u" # this is done on purpose (see iperf.sh)
        #fi
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      mpi)
        valid_flags="-h --help -p --processes"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        valid_flags="-c --commit -d --device -h --help"
        echo ""
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      vitis)
        valid_flags="-d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      vitis-ai)
        valid_flags="-d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      *)
        validate_help
        ;;
    esac
    ;;
  *)
    cli_help
    ;;
esac

#author: https://github.com/jmoya82
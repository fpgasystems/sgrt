#!/bin/bash

CLI_PATH=$(dirname "$0")
CLI_NAME=${0##*/}
SGRT_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#example: sgutil program opennic --device 1

#inputs
command=$1
arguments=$2

#constants
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
ONIC_DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
ONIC_DRIVER_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_REPO)
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_SHELL_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
ONIC_SHELL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_REPO)
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#get devices number
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"
MAX_DEVICES=$($CLI_PATH/common/get_max_devices "fpga|acap" $DEVICES_LIST)
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#help
cli_help() {
  echo "
${bold}$CLI_NAME [commands] [arguments [flags]] [--help] [--version]${normal}

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

#dialog messages
CHECK_ON_DEVICE_MSG="${bold}Please, choose your device:${normal}"
CHECK_ON_NEW_MSG="${bold}Please, type a non-existing name for your project:${normal}"
CHECK_ON_PLATFORM_MSG="${bold}Please, choose your platform:${normal}"
CHECK_ON_PROJECT_MSG="${bold}Please, choose your project:${normal}"
CHECK_ON_PUSH_MSG="${bold}Would you like to add the project to your GitHub account (y/n)?${normal}"
CHECK_ON_REMOTE_MSG="${bold}Please, choose your deployment servers:${normal}"

#error messages
CHECK_ON_BITSTREAM_ERR_MSG="Your targeted bitstream is missing. Please, use ${bold}$CLI_NAME build WILL_BE_REPLACED.${normal}"
CHECK_ON_COMMIT_ERR_MSG="Please, choose a valid commit ID."
CHECK_ON_DEVICE_ERR_MSG="Please, choose a valid device index."
CHECK_ON_DRIVER_ERR_MSG="Your targeted driver is missing. Please, use ${bold}$CLI_NAME build WILL_BE_REPLACED.${normal}"
CHECK_ON_FPGA_ERR_MSG="Sorry, this command is not available on $hostname."
CHECK_ON_GH_ERR_MSG="Please, use ${bold}$CLI_NAME set gh${normal} to log in to your GitHub account."
CHECK_ON_PLATFORM_ERR_MSG="Please, choose a valid platform name."
CHECK_ON_PROJECT_ERR_MSG="Please, choose a valid project name."
CHECK_ON_PUSH_ERR_MSG="Please, choose a valid push option."
CHECK_ON_REMOTE_ERR_MSG="Please, choose a valid deploy option."
CHECK_ON_VIRTUALIZED_ERR_MSG="Sorry, this command is not available on $hostname."
CHECK_ON_VIVADO_ERR_MSG="Please, choose a valid Vivado version."
CHECK_ON_VIVADO_DEVELOPERS_ERR_MSG="Sorry, this command is not available for $USER."

bitstream_check() {
  local CLI_NAME=$1
  local WORKFLOW=$2
  local BITSTREAM_PATH=$3
  if ! [ -e "$BITSTREAM_PATH" ]; then
    #echo ""
    #CHECK_ON_BITSTREAM_ERR_MSG="${CHECK_ON_BITSTREAM_ERR_MSG//WILL_BE_REPLACED/$WORKFLOW}"
    echo "${CHECK_ON_BITSTREAM_ERR_MSG//WILL_BE_REPLACED/$WORKFLOW}"
    echo ""
    exit 1
  fi
}

commit_dialog() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local MY_PROJECTS_PATH=$3
  local command=$4 #program
  local WORKFLOW=$5 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$6
  local REPO_ADDRESS=$7
  local DEFAULT_COMMIT=$8
  shift 8
  local flags_array=("$@")
  
  commit_found=""
  commit_name=""
  if [ "$flags_array" = "" ]; then
    #check on PWD
    project_path=$(dirname "$PWD")
    commit_name=$(basename "$project_path")
    project_found="0"
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
        commit_found="1"
        project_found="1"
        project_name=$(basename "$PWD")
    elif [ "$commit_name" = "$WORKFLOW" ]; then
        commit_found="1"
        commit_name="${PWD##*/}"
    else
        commit_found="1"
        commit_name=$DEFAULT_COMMIT
    fi
  else
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$WORKFLOW" "$GITHUB_CLI_PATH" "$REPO_ADDRESS" "$DEFAULT_COMMIT" "${flags_array[@]}"
  fi
}

commit_check() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3 #program
  local WORKFLOW=$4 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$5
  local REPO_ADDRESS=$6
  local DEFAULT_COMMIT=$7
  shift 7
  local flags_array=("$@")
  #commit_dialog_check
  result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
  commit_found=$(echo "$result" | sed -n '1p')
  commit_name=$(echo "$result" | sed -n '2p')
  #check if commit exists
  exists=$($GITHUB_CLI_PATH/gh api repos/$REPO_ADDRESS/commits/$commit_name 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
  #forbidden combinations
  if [ "$commit_found" = "0" ]; then 
      commit_found="1"
      commit_name=$DEFAULT_COMMIT
  elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ]); then 
      $CLI_PATH/help/${command}"_"${WORKFLOW} $CLI_PATH $CLI_NAME
      exit 1
  elif [ "$commit_found" = "1" ] && [ "$exists" = "0" ]; then 
      echo ""
      echo $CHECK_ON_COMMIT_ERR_MSG
      echo ""
      exit 1
  fi
}

device_dialog() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3
  local arguments=$4
  local multiple_devices=$5
  local MAX_DEVICES=$6
  shift 6
  local flags_array=("$@")
  
  device_found=""
  device_index=""
  if [ "$flags_array" = "" ]; then
      #device_dialog
      if [[ $multiple_devices = "0" ]]; then
          device_found="1"
          device_index="1"
      else
          echo $CHECK_ON_DEVICE_MSG
          echo ""
          result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
          device_found=$(echo "$result" | sed -n '1p')
          device_index=$(echo "$result" | sed -n '2p')
      fi
  else
      device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
      #forgotten mandatory
      if [[ $multiple_devices = "0" ]]; then
          device_found="1"
          device_index="1"
      elif [[ $device_found = "0" ]]; then
          echo $CHECK_ON_DEVICE_MSG
          echo ""
          result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
          device_found=$(echo "$result" | sed -n '1p')
          device_index=$(echo "$result" | sed -n '2p')
          echo ""
      fi
  fi
}

device_check() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3
  local arguments=$4
  local multiple_devices=$5
  local MAX_DEVICES=$6
  shift 6
  local flags_array=("$@")
  result="$("$CLI_PATH/common/device_dialog_check" "${flags_array[@]}")"
  device_found=$(echo "$result" | sed -n '1p')
  device_index=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]); then
      $CLI_PATH/help/${command}"_"${arguments} $CLI_PATH $CLI_NAME
      exit 1
  elif ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
    echo ""
    echo $CHECK_ON_DEVICE_ERR_MSG
    echo ""
    exit
  fi
}

driver_check() {
  local CLI_NAME=$1
  local WORKFLOW=$2
  local DRIVER_PATH=$3
  if ! [ -e "$DRIVER_PATH" ]; then
    #echo ""
    #CHECK_ON_BITSTREAM_ERR_MSG="${CHECK_ON_BITSTREAM_ERR_MSG//WILL_BE_REPLACED/$WORKFLOW}"
    echo "${CHECK_ON_DRIVER_ERR_MSG//WILL_BE_REPLACED/$WORKFLOW}"
    echo ""
    exit 1
  fi
}

flags_check() {
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

fpga_check() {
  local CLI_PATH=$1
  local hostname=$2
  acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
      echo ""
      echo $CHECK_ON_FPGA_ERR_MSG
      echo ""
      exit 1
  fi
}

gh_check() {
  local CLI_PATH=$1
  logged_in=$($CLI_PATH/common/gh_auth_status)
  if [ "$logged_in" = "0" ]; then 
    echo ""
    echo $CHECK_ON_GH_ERR_MSG
    echo ""
    exit 1
  fi
}

new_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")

  new_found=""
  new_name=""

  if [ "$flags_array" = "" ]; then
    #new_dialog
    echo $CHECK_ON_NEW_MSG
    echo ""
    result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name)
    new_found=$(echo "$result" | sed -n '1p')
    new_name=$(echo "$result" | sed -n '2p')
    echo ""
  else
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $new_found = "0" ]]; then
        echo $CHECK_ON_NEW_MSG
        result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name)
        new_found=$(echo "$result" | sed -n '1p')
        new_name=$(echo "$result" | sed -n '2p')
        echo ""
    fi
  fi
}

new_check(){
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")
  #new_dialog_check
  result="$("$CLI_PATH/common/new_dialog_check" "${flags_array[@]}")"
  new_found=$(echo "$result" | sed -n '1p')
  new_name=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$new_found" = "1" ] && ([ "$new_name" = "" ] || [ -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$new_name" ]); then 
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  fi
}

platform_dialog() {
  local CLI_PATH=$1
  local XILINX_PLATFORMS_PATH=$2
  #local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  shift 2
  local flags_array=("$@")

  platform_found=""
  platform_name=""

  if [ "$flags_array" = "" ]; then
    echo $CHECK_ON_PLATFORM_MSG
    echo ""
    result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
    platform_found=$(echo "$result" | sed -n '1p')
    platform_name=$(echo "$result" | sed -n '2p')
    multiple_platforms=$(echo "$result" | sed -n '3p')
    if [[ $multiple_platforms = "0" ]]; then
        echo $platform_name
    fi
    echo ""
  else
    platform_check "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $platform_found = "0" ]]; then
        echo $CHECK_ON_PLATFORM_MSG
        echo ""
        result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
        platform_found=$(echo "$result" | sed -n '1p')
        platform_name=$(echo "$result" | sed -n '2p')
        multiple_platforms=$(echo "$result" | sed -n '3p')
        if [[ $multiple_platforms = "0" ]]; then
            echo $platform_name
        fi
        echo ""
    fi
  fi
}

platform_check() {
  local CLI_PATH=$1
  local XILINX_PLATFORMS_PATH=$2
  #local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  shift 2
  local flags_array=("$@")
  result="$("$CLI_PATH/common/platform_dialog_check" "${flags_array[@]}")"
  platform_found=$(echo "$result" | sed -n '1p')
  platform_name=$(echo "$result" | sed -n '2p')    
  #forbidden combinations
  if ([ "$platform_found" = "1" ] && [ "$platform_name" = "" ]) || ([ "$platform_found" = "1" ] && [ ! -d "$XILINX_PLATFORMS_PATH/$platform_name" ]); then
      echo ""
      echo $CHECK_ON_PLATFORM_ERR_MSG
      echo ""
      exit 1
  fi
}

project_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  #local command=$3
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  shift 4
  local flags_array=("$@")

  project_found="0"
  project_name=""

  #check on PWD
  project_path=$(dirname "$PWD")  
  if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
      project_found="1"
      project_name=$(basename "$PWD")
      return 1
  fi
  
  if [ "$flags_array" = "" ]; then
    #project_dialog
    if [[ $project_found = "0" ]]; then
      echo $CHECK_ON_PROJECT_MSG
      echo ""
      result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
      project_found=$(echo "$result" | sed -n '1p')
      project_name=$(echo "$result" | sed -n '2p')
      multiple_projects=$(echo "$result" | sed -n '3p')
      if [[ $multiple_projects = "0" ]]; then
          echo $project_name
      fi
      echo ""
    fi
  else
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $project_found = "0" ]]; then
        #echo ""
        echo $CHECK_ON_PROJECT_MSG
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
        project_found=$(echo "$result" | sed -n '1p')
        project_name=$(echo "$result" | sed -n '2p')
        multiple_projects=$(echo "$result" | sed -n '3p')
        if [[ $multiple_projects = "0" ]]; then
            echo $project_name
        fi
        echo ""
    fi
  fi
}

project_check() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  shift 4
  local flags_array=("$@")
  result="$("$CLI_PATH/common/project_dialog_check" "${flags_array[@]}")"
  project_found=$(echo "$result" | sed -n '1p')
  project_path=$(echo "$result" | sed -n '2p')
  project_name=$(echo "$result" | sed -n '3p')
  #forbidden combinations
  if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$project_path" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]); then  
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  fi
}

push_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")

  push_found=""
  push_option=""

  #capture gh auth status
  logged_in=$($CLI_PATH/common/gh_auth_status)

  if [ "$flags_array" = "" ]; then
    #push_dialog
    push_option="0"
    if [ "$logged_in" = "1" ]; then
        echo $CHECK_ON_PUSH_MSG
        push_option=$($CLI_PATH/common/push_dialog)
        echo ""
    fi
  else
    push_check "$CLI_PATH" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $push_found = "0" ]]; then
        push_option="0"
        if [ "$logged_in" = "1" ]; then
            echo $CHECK_ON_PUSH_MSG
            push_option=$($CLI_PATH/common/push_dialog)
            echo ""
        fi
    fi
  fi
}

push_check(){
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  #push_dialog_check
  result="$("$CLI_PATH/common/push_dialog_check" "${flags_array[@]}")"
  push_found=$(echo "$result" | sed -n '1p')
  push_option=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [[ "$push_found" = "1" && "$push_option" != "0" && "$push_option" != "1" ]]; then 
      echo ""
      echo "$CHECK_ON_PUSH_ERR_MSG"
      echo ""
      exit 1
  fi
}

remote_dialog() {
  local CLI_PATH=$1
  local command=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local hostname=$4
  local username=$5
  shift 5
  local flags_array=("$@")

  #combine ACAP and FPGA lists removing duplicates
  SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST /$CLI_PATH/constants/FPGA_SERVERS_LIST)

  if [ "$flags_array" = "" ]; then
    result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
    servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
    servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
    num_remote_servers=$(echo "$servers_family_list" | wc -w)
    #deployment_dialog
    deploy_option="0"
    if [ "$num_remote_servers" -ge 1 ]; then
        #echo ""
        echo $CHECK_ON_REMOTE_MSG
        echo ""
        echo "0) $hostname"
        echo "1) $hostname, $servers_family_list_string"
        deploy_option=$($CLI_PATH/common/deployment_dialog $servers_family_list_string)
        echo ""
    fi
  else
    remote_check "$CLI_PATH" "${flags_array[@]}"
    #forgotten mandatory
    result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
    servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
    servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
    num_remote_servers=$(echo "$servers_family_list" | wc -w)
    if [ "$deploy_option_found" = "0" ]; then
        #deployment_dialog
        deploy_option="0"
        if [ "$num_remote_servers" -ge 1 ]; then
            #echo ""
            echo $CHECK_ON_REMOTE_MSG
            echo ""
            echo "0) $hostname"
            echo "1) $hostname, $servers_family_list_string"
            deploy_option=$($CLI_PATH/common/deployment_dialog $servers_family_list_string)
            echo ""
        fi
    fi
  fi
}

remote_check() {
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  result="$("$CLI_PATH/common/deployment_dialog_check" "${flags_array[@]}")"
  deploy_option_found=$(echo "$result" | sed -n '1p')
  deploy_option=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$deploy_option_found" = "1" ] && { [ "$deploy_option" -ne 0 ] && [ "$deploy_option" -ne 1 ]; }; then
      echo ""
      echo $CHECK_ON_REMOTE_ERR_MSG
      echo ""
      exit 1
  fi
}

virtualized_check() {
  local CLI_PATH=$1
  local hostname=$2
  virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
  if [ "$virtualized" = "1" ]; then
      echo ""
      echo $CHECK_ON_VIRTUALIZED_ERR_MSG
      echo ""
      exit 1
  fi
}

vivado_check() {
  local VIVADO_PATH=$1
  local vivado_version=$2
  if [ ! -d $VIVADO_PATH/$vivado_version ]; then
    echo ""
    echo $CHECK_ON_VIVADO_ERR_MSG
    echo ""
    exit 1
  fi
}

vivado_developers_check() {
  local username=$1
  member=$($CLI_PATH/common/is_member $username vivado_developers)
  if [ "$member" = "false" ]; then
      echo ""
      echo $CHECK_ON_VIVADO_DEVELOPERS_ERR_MSG
      echo ""
      exit 1
  fi
}

# build ------------------------------------------------------------------------------------------------------------------------

build_help() {
    echo ""
    echo "${bold}$CLI_NAME build [arguments [flags]] [--help]${normal}"
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
    echo "${bold}$CLI_NAME build coyote [flags] [--help]${normal}"
    echo ""
    echo "Generates Coyote's bitstreams and drivers."
    echo ""
    echo "FLAGS:"
    #echo "   -c, --config    - Coyote's configuration:"
    #echo "                         perf_hosts, perf_fpga, gbm_dtrees,"
    #echo "                         hyperloglog, perf_dram, perf_hbm,"
    #echo "                         perf_rdma_host, perf_rdma_card, perf_tcp,"
    #echo "                         rdma_regex, service_aes, service_reconfiguration."
    echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
    echo "       --platform  - Xilinx platform (according to $CLI_NAME get platform)."
    echo "       --project   - Specifies your Coyote project name."
    echo ""
    echo "   -h, --help      - Help to build Coyote."
    echo ""
    exit 1
}

build_hip_help() {
    echo ""
    echo "${bold}$CLI_NAME build hip [flags] [--help]${normal}"
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
    echo "${bold}$CLI_NAME build mpi [flags] [--help]${normal}"
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
    $CLI_PATH/help/build_opennic $CLI_PATH $CLI_NAME
    exit
}

build_vitis_help() {
    echo ""
    echo "${bold}$CLI_NAME build vitis [flags] [--help]${normal}"
    echo ""
    echo "Uses acap_fpga_xclbin to generate XCLBIN binaries for Vitis workflow."
    echo ""
    echo "FLAGS:"
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
    echo "${bold}$CLI_NAME build vivado [flags] [--help]${normal}"
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
    echo "${bold}$CLI_NAME enable [arguments [flags]] [--help]${normal}"
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
    echo "${bold}$CLI_NAME enable vitis [--help]${normal}"
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
    echo "${bold}$CLI_NAME enable vivado [--help]${normal}"
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
    echo "${bold}$CLI_NAME enable xrt [--help]${normal}"
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
    echo "${bold}$CLI_NAME examine [--help]${normal}"
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
    echo "${bold}$CLI_NAME get [arguments [flags]] [--help]${normal}"
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
    echo "${bold}$CLI_NAME get bdf [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Bus Device Function."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_clock_help() {
    echo ""
    echo "${bold}$CLI_NAME get clock [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Clock Information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_bus_help() {
    echo ""
    echo "${bold}$CLI_NAME get bus [flags] [--help]${normal}"
    echo ""
    echo "Retreives GPU PCI Bus ID."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - GPU Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_memory_help() {
    echo ""
    echo "${bold}$CLI_NAME get clock [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Memory Information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_name_help() {
    echo ""
    echo "${bold}$CLI_NAME get name [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP device names."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_ifconfig_help() {
    echo ""
    echo "${bold}$CLI_NAME get ifconfig [--help]${normal}"
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
    echo "${bold}$CLI_NAME get network [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP networking information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_platform_help() {
    echo ""
    echo "${bold}$CLI_NAME get platform [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP platform names."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_resource_help() {
    echo ""
    echo "${bold}$CLI_NAME get resource [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Resource Availability."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_serial_help() {
    echo ""
    echo "${bold}$CLI_NAME get serial [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP serial numbers."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_slr_help() {
    echo ""
    echo "${bold}$CLI_NAME get slr [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP Retreives FPGA/ACAP Resource Availability and Memory Information per SLR."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_syslog_help() {
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
    exit 1
}

get_workflow_help() {
    echo ""
    echo "${bold}$CLI_NAME get workflow [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA/ACAP current workflow."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA/ACAP Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_servers_help() {
    echo ""
    echo "${bold}$CLI_NAME get servers [--help]${normal}"
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
    echo "${bold}$CLI_NAME new [arguments] [--help]${normal}"
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
    $CLI_PATH/help/new_coyote $CLI_PATH $CLI_NAME
    exit
}

new_hpi_help() {
    echo ""
    echo "${bold}$CLI_NAME new hip [--help]${normal}"
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
    echo "${bold}$CLI_NAME new mpi [--help]${normal}"
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
    $CLI_PATH/help/new_opennic $CLI_PATH $CLI_NAME
    exit
}

new_vitis_help() {
    echo ""
    echo "${bold}$CLI_NAME new vitis [--help]${normal}"
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
    echo "${bold}$CLI_NAME program [arguments [flags]] [--help]${normal}"
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
    echo "${bold}$CLI_NAME program coyote [flags] [--help]${normal}"
    echo ""
    echo "Programs Coyote to a given FPGA."
    echo ""
    echo "FLAGS:"
    echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
    echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
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
    echo "${bold}$CLI_NAME program driver [flags] [--help]${normal}"
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
    $CLI_PATH/help/program_opennic $CLI_PATH $CLI_NAME
    exit
}

program_reset_help() {
    echo ""
    echo "${bold}$CLI_NAME program reset [flags] [--help]${normal}"
    echo ""
    echo "Resets a given FPGA/ACAP."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

program_revert_help() {
    $CLI_PATH/help/program_revert $CLI_NAME
    exit 
}

program_vivado_help() {
    echo ""
    echo "${bold}$CLI_NAME program vivado [flags] [--help]${normal}"
    echo ""
    echo "Programs a Vivado bitstream to a given FPGA."
    echo ""
    echo "FLAGS:"
    echo "   -b, --bitstream - Full path to the .bit bitstream to be programmed." 
    echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
    #echo "       --driver    - Driver (.ko) file path."
    echo ""
    echo "   -h, --help      - Help to program a bitstream."
    echo ""
    exit 1
}

program_vitis_help() {
    echo ""
    echo "${bold}$CLI_NAME program vitis [flags] [--help]${normal}"
    echo ""
    echo "Programs a Vitis binary to a given FPGA/ACAP."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
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
    echo "${bold}$CLI_NAME reboot [--help]${normal}"
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
    echo "${bold}$CLI_NAME run [arguments [flags]] [--help]${normal}"
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
    echo "${bold}$CLI_NAME run coyote [flags] [--help]${normal}"
    echo ""
    echo "Runs Coyote on a given FPGA."
    echo ""
    echo "FLAGS:"
    echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
    echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
    echo "   -p, --project   - Specifies your Coyote project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

run_hip_help() {
    echo ""
    echo "${bold}$CLI_NAME run hip [flags] [--help]${normal}"
    echo ""
    echo "Runs your HIP application on a given GPU."
    echo ""
    echo "FLAGS"
    echo "   -d, --device    - GPU Device Index (see $CLI_NAME examine)."
    echo "   -p, --project   - Specifies your HIP project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

run_mpi_help() {
    echo ""
    echo "${bold}$CLI_NAME run mpi [flags] [--help]${normal}"
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
    echo "${bold}$CLI_NAME run vitis [flags] [--help]${normal}"
    echo ""
    echo "Runs a Vitis FPGA-binary on a given FPGA/ACAP."
    echo ""
    echo "FLAGS:"
    #echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
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
    echo "${bold}$CLI_NAME set [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Devices and host configuration."
    echo ""
    echo "ARGUMENTS:"
    echo "   gh              - Enables GitHub CLI on your host (default path: ${bold}$GITHUB_CLI_PATH${normal})."
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
    echo "${bold}$CLI_NAME set gh [--help]${normal}"
    echo ""
    echo "Enables GitHub CLI on your host (default path: ${bold}$GITHUB_CLI_PATH${normal})."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

set_keys_help() {
  $CLI_PATH/help/set_keys $CLI_NAME
  exit
}

set_license_help() {
    echo ""
    echo "${bold}$CLI_NAME set license [--help]${normal}"
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
    echo "${bold}$CLI_NAME set mtu [flags] [--help]${normal}"
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

# validate -----------------------------------------------------------------------------------------------------------------------
validate_help() {
    echo ""
    echo "${bold}$CLI_NAME validate [arguments [flags]] [--help]${normal}"
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
      echo "${bold}$CLI_NAME validate coyote [flags] [--help]${normal}"
      echo ""
      echo "Validates Coyote on the selected FPGA."
      echo ""
      echo "FLAGS:"
      echo "   -c, --commit    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
      echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
      echo ""
      echo "   -h, --help      - Help to use Coyote validation."
      echo ""
      exit 1
}

validate_docker_help() {
      echo ""
      echo "${bold}$CLI_NAME validate docker [--help]${normal}"
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
      echo "${bold}$CLI_NAME validate hip [flags] [--help]${normal}"
      echo ""
      echo "Validates HIP on the selected GPU."
      echo ""
      echo "FLAGS:"
      echo "   -d, --device    - GPU Device Index (see $CLI_NAME examine)."
      echo ""
      echo "   -h, --help      - Help to use HIP validation."
      echo ""
      exit 1
}

validate_iperf_help() {
      echo ""
      echo "${bold}$CLI_NAME validate iperf [flags] [--help]${normal}"
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
      echo "${bold}$CLI_NAME validate mpi [flags] [--help]${normal}"
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
    $CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
    exit
}

validate_vitis_help() {
      echo ""
      echo "${bold}$CLI_NAME validate vitis [flags] [--help]${normal}"
      echo ""
      echo "Validates Vitis workflow on the selected FPGA/ACAP."
      echo ""
      echo "FLAGS:"
      echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
      echo ""
      echo "   -h, --help      - Help to use Vitis validation."
      echo ""
      exit 1
}

validate_vitis_ai_help() {
      echo ""
      echo "${bold}$CLI_NAME validate vitis-ai [flags] [--help]${normal}"
      echo ""
      echo "Validates Vitis AI workflow on the selected FPGA????????/ACAP."
      echo ""
      echo "FLAGS:"
      echo "   -d, --device    - FPGA Device Index (see $CLI_NAME examine)."
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

#command and arguments switch
case "$command" in
  -h|--help)
    cli_help
    ;;
  -v|--version)
    cli_version
    ;;
  build)
    #checks
    if [ "$arguments" = "coyote" ] || [ "$arguments" = "opennic" ]; then
      vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
      vivado_check "$VIVADO_PATH" "$vivado_version"
      vivado_developers_check "$USER"
      gh_check "$CLI_PATH"
    fi

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
        #check on flags
        valid_flags="-c --commit --platform --project -h --help" 
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          platform_check "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        fi
        
        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID for shell: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        commit_name_driver=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/ONIC_DRIVER_COMMIT)
        platform_dialog "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "${flags_array[@]}"
        
        #run
        $CLI_PATH/build/opennic --commit $commit_name $commit_name_driver --platform $platform_name --project $project_name --version $vivado_version
        echo ""
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
    #create workflow directory
    if [ "$arguments" = "coyote" ] || [ "$arguments" = "hip" ] || [ "$arguments" = "opennic" ]; then
      #create directory
      mkdir -p "$MY_PROJECTS_PATH/$arguments"
    fi

    #checks
    if [ "$arguments" = "coyote" ] || [ "$arguments" = "opennic" ]; then
      vivado_developers_check "$USER"
      gh_check "$CLI_PATH"
    fi

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
        #check on flags
        valid_flags="-c --commit --project --push -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check_on_commits
        commit_found_shell=""
        commit_name_shell=""
        commit_found_driver=""
        commit_name_driver=""
        if [ "$flags_array" = "" ]; then
            #commit dialog
            commit_found_shell="1"
            commit_found_driver="1"
            commit_name_shell=$ONIC_SHELL_COMMIT
            commit_name_driver=$ONIC_DRIVER_COMMIT
            #checks (command line)
            device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        else
            #commit_dialog_check
            result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
            commit_found=$(echo "$result" | sed -n '1p')
            commit_name=$(echo "$result" | sed -n '2p')

            #check if commit_name is empty
            if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
                $CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
                exit
            fi
            
            #check if commit_name contains exactly one comma
            if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
                echo ""
                echo "Please, choose valid shell and driver commit IDs."
                echo ""
                exit
            fi
            
            #get shell and driver commits (shell_commit,driver_commit)
            commit_name_shell=${commit_name%%,*}
            commit_name_driver=${commit_name#*,}

            #check if commits exist
            exists_shell=$($GITHUB_CLI_PATH/gh api repos/$ONIC_SHELL_REPO/commits/$commit_name_shell 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
            exists_driver=$($GITHUB_CLI_PATH/gh api repos/$ONIC_DRIVER_REPO/commits/$commit_name_driver 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')

            if [ "$commit_found" = "0" ]; then 
                commit_name_shell=$ONIC_SHELL_COMMIT
                commit_name_driver=$ONIC_DRIVER_COMMIT
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ]); then 
                $CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
                exit
            elif [ "$commit_found" = "1" ] && ([ "$exists_shell" = "0" ] || [ "$exists_driver" = "0" ]); then 
                if [ "$exists_shell" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid shell commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
                if [ "$exists_driver" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid driver commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
            fi
        fi

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
          push_check "$CLI_PATH" "${flags_array[@]}"
        fi
        
        #vivado_developers_check "$USER"
        #gh_check "$CLI_PATH"

        #dialogs
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name_shell)${normal}"
        echo ""
        new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
        push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
  

        echo "commit_name_shell: $commit_name_shell"
        echo "commit_name_driver: $commit_name_driver"
        echo "new_name: $new_name" 
        echo "push_option: $push_option" 

        exit

        #run
        $CLI_PATH/new/opennic --commit $commit_name_shell $commit_name_driver --project $new_name --push $push_option
        echo ""

        #valid_flags="-c --commit --project --push -h --help"
        #echo ""
        #command_run $command_arguments_flags"@"$valid_flags
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
    #checks (1/2)
    if [ "$arguments" = "coyote" ] || [ "$arguments" = "opennic" ] || [ "$arguments" = "revert" ]; then
      virtualized_check "$CLI_PATH" "$hostname"
      fpga_check "$CLI_PATH" "$hostname"
      vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
      vivado_check "$VIVADO_PATH" "$vivado_version"
    fi

    #checks (2/2)
    if [ "$arguments" = "coyote" ] || [ "$arguments" = "opennic" ]; then
      vivado_developers_check "$USER"
      gh_check "$CLI_PATH"
    fi
    
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
        #check on flags
        valid_flags="-c --commit -d --device -p --project --remote -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
          remote_check "$CLI_PATH" "${flags_array[@]}"
        fi
        
        #vivado_developers_check "$USER"
        #gh_check "$CLI_PATH"

        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        if [[ "$flags_array" = "" ]] && [[ $multiple_devices = "1" ]]; then
          echo ""
        fi
        
        FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)
        bitstream_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
        bitstream_check "$CLI_NAME" "$arguments" "$bitstream_path"

        driver_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/$ONIC_DRIVER_NAME"
        driver_check "$CLI_NAME" "$arguments" "$driver_path"

        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #run
        $CLI_PATH/program/opennic --commit $commit_name --device $device_index --project $project_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}" 
        ;;
      reset) 
        valid_flags="-d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      revert)
        #check on flags
        valid_flags="-d --device -v --version -h --help" # -v --version are not exposed and not shown in help command or completion
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        fi
        
        if [[ "$flags_array" = "" ]] && [[ $multiple_devices = "1" ]]; then
            echo ""
            echo "${bold}$CLI_NAME $command $arguments${normal}"
            echo ""
        fi

        #dialogs
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        if [[ "$flags_array" = "" ]] && [[ $multiple_devices = "1" ]]; then
            workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
            if [[ $workflow = "vitis" ]]; then
                echo ""
            fi
        fi
        workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
        if [[ $workflow = "vitis" ]]; then
            exit
        fi
        echo ""

        #run
        $CLI_PATH/program/revert --device $device_index --version $vivado_version
        echo ""
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
        echo ""
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
    #create workflow directory
    if [ "$arguments" = "coyote" ] || [ "$arguments" = "hip" ] || [ "$arguments" = "opennic" ]; then
      mkdir -p "$MY_PROJECTS_PATH/$arguments"
    fi

    #checks
    if [ "$arguments" = "coyote" ] || [ "$arguments" = "opennic" ]; then
      virtualized_check "$CLI_PATH" "$hostname"
      fpga_check "$CLI_PATH" "$hostname"
      vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
      vivado_check "$VIVADO_PATH" "$vivado_version"
      vivado_developers_check "$USER"
      gh_check "$CLI_PATH"
    fi

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
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      mpi)
        valid_flags="-h --help -p --processes"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        #check on flags
        valid_flags="-c --commit -d --device -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check_on_commits
        commit_found_shell=""
        commit_name_shell=""
        commit_found_driver=""
        commit_name_driver=""
        if [ "$flags_array" = "" ]; then
            #commit dialog
            commit_found_shell="1"
            commit_found_driver="1"
            commit_name_shell=$ONIC_SHELL_COMMIT
            commit_name_driver=$ONIC_DRIVER_COMMIT
            #checks (command line)
            device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        else
            #commit_dialog_check
            result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
            commit_found=$(echo "$result" | sed -n '1p')
            commit_name=$(echo "$result" | sed -n '2p')

            #check if commit_name is empty
            if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
                $CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
                exit
            fi
            
            #check if commit_name contains exactly one comma
            if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
                echo ""
                echo "Please, choose valid shell and driver commit IDs."
                echo ""
                exit
            fi
            
            #get shell and driver commits (shell_commit,driver_commit)
            commit_name_shell=${commit_name%%,*}
            commit_name_driver=${commit_name#*,}

            #check if commits exist
            exists_shell=$($GITHUB_CLI_PATH/gh api repos/$ONIC_SHELL_REPO/commits/$commit_name_shell 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')
            exists_driver=$($GITHUB_CLI_PATH/gh api repos/$ONIC_DRIVER_REPO/commits/$commit_name_driver 2>/dev/null | jq -r 'if has("sha") then "1" else "0" end')

            if [ "$commit_found" = "0" ]; then 
                commit_name_shell=$ONIC_SHELL_COMMIT
                commit_name_driver=$ONIC_DRIVER_COMMIT
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ]); then 
                $CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
                exit
            elif [ "$commit_found" = "1" ] && ([ "$exists_shell" = "0" ] || [ "$exists_driver" = "0" ]); then 
                if [ "$exists_shell" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid shell commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
                if [ "$exists_driver" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid driver commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
            fi
        fi
        #echo ""

        #dialogs
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        echo ""

        echo "${bold}$CLI_NAME $command $arguments (shell and driver commit IDs: $commit_name_shell,$commit_name_driver)${normal}"
        echo ""
        
        #run
        $CLI_PATH/validate/opennic --commit $commit_name_shell $commit_name_driver --device $device_index --version $vivado_version
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
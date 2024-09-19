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
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
ONIC_DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
ONIC_DRIVER_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_REPO)
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_SHELL_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
ONIC_SHELL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_REPO)
REPO_NAME="sgrt"
UPDATES_PATH=$($CLI_PATH/common/get_constant $CLI_PATH UPDATES_PATH)
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#derived
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
REPO_URL="https://github.com/fpgasystems/$REPO_NAME.git"
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#check on server
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_cpu=$($CLI_PATH/common/is_cpu $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
is_virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)

#check on groups
is_sudo=$($CLI_PATH/common/is_sudo $USER)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)

#get devices number
if [ -s "$DEVICES_LIST" ]; then
  source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"
  MAX_DEVICES=$($CLI_PATH/common/get_max_devices "fpga|acap|asoc" $DEVICES_LIST)
  multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)
fi

#help
cli_help() {
  echo ""
  echo "${bold}$CLI_NAME [commands] [arguments [flags]] [--help] [--release]${normal}"
  echo ""
  echo "COMMANDS:"
  echo "    build           - Creates binaries, bitstreams, and drivers for your accelerated applications."
  if [ "$is_cpu" = "1" ]; then
  echo "    enable          - Enables your favorite development and deployment tools."
  fi
  echo "    examine         - Status of the system and devices."
  echo "    get             - Devices and host information."
  echo "    new             - Creates a new project of your choice."
  if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
  echo "    program         - Download the acceleration program to a given FPGA."
  fi
  if [ "$is_sudo" = "1" ] || ([ "$is_cpu" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
  echo "    reboot          - Reboots the server (warm boot)."
  fi
  if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ] || [ "$is_gpu" = "1" ]; then
  echo "    run             - Executes the accelerated application on a given device."
  fi
  echo "    set             - Devices and host configuration."
  if [ "$is_sudo" = "1" ]; then
  echo "    update          - Updates $CLI_NAME to its latest version."
  fi
  if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ] || [ "$is_gpu" = "1" ]; then
  echo "    validate        - Validates the basic HACC infrastructure functionality."
  fi
  echo ""
  echo "    -h, --help      - Help to use $CLI_NAME."
  echo "    -r, --release   - Reports $CLI_NAME release."
  echo ""
  exit 1
}

cli_release() {
    release=$(cat $SGRT_PATH/COMMIT)
    release_date=$(cat $SGRT_PATH/COMMIT_DATE)
    echo ""
    echo "Release (commit_ID) : $release ($release_date)"
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
CHECK_ON_CONFIG_MSG="${bold}Please, choose your configuration:${normal}"
CHECK_ON_DEVICE_MSG="${bold}Please, choose your device:${normal}"
CHECK_ON_NEW_MSG="${bold}Please, type a non-existing name for your project:${normal}"
CHECK_ON_PLATFORM_MSG="${bold}Please, choose your platform:${normal}"
CHECK_ON_PROJECT_MSG="${bold}Please, choose your project:${normal}"
CHECK_ON_PUSH_MSG="${bold}Would you like to add the project to your GitHub account (y/n)?${normal}"
CHECK_ON_REMOTE_MSG="${bold}Please, choose your deployment servers:${normal}"

#error messages
CHECK_ON_XRT_SHELL_ERR_MSG="Sorry, this command is only available for XRT shells."
CHECK_ON_BITSTREAM_ERR_MSG="Your targeted bitstream is missing."
CHECK_ON_COMMIT_ERR_MSG="Please, choose a valid commit ID."
CHECK_ON_CONFIG_ERR_MSG="Please, create a valid configuration first."
CHECK_ON_DEVICE_ERR_MSG="Please, choose a valid device index."
CHECK_ON_DRIVER_ERR_MSG="Please, choose a valid driver name."
CHECK_ON_DRIVER_PARAMS_ERR_MSG="Please, choose a valid list of module parameters." 
CHECK_ON_FEC_ERR_MSG="Please, choose a valid FEC option."
CHECK_ON_GH_ERR_MSG="Please, use ${bold}$CLI_NAME set gh${normal} to log in to your GitHub account."
CHECK_ON_HOSTNAME_ERR_MSG="Sorry, this command is not available on $hostname."
CHECK_ON_PLATFORM_ERR_MSG="Please, choose a valid platform name."
CHECK_ON_PROJECT_ERR_MSG="Please, choose a valid project name."
CHECK_ON_PUSH_ERR_MSG="Please, choose a valid push option."
CHECK_ON_REMOTE_ERR_MSG="Please, choose a valid deploy option."
CHECK_ON_SUDO_ERR_MSG="Sorry, this command requires sudo capabilities."
CHECK_ON_VIVADO_ERR_MSG="Please, choose a valid Vivado version."
CHECK_ON_VIVADO_DEVELOPERS_ERR_MSG="Sorry, this command is not available for $USER."
CHECK_ON_WORKFLOW_ERR_MSG="Please, program your device first."
CHECK_ON_XRT_ERR_MSG="Please, choose a valid XRT version."

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
  exists=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $REPO_ADDRESS $commit_name)
  #forbidden combinations
  if [ "$commit_found" = "0" ]; then 
    commit_found="1"
    commit_name=$DEFAULT_COMMIT
  elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ] || [ "$exists" = "0" ]); then 
      echo ""
      echo $CHECK_ON_COMMIT_ERR_MSG
      echo ""
      exit 1
  fi
}

config_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3
  local commit_name=$4
  local project_name=$5
  #local file_name=$6
  local config_prefix=$6
  shift 6
  local flags_array=("$@")

  config_found=""
  config_name=""
  config_index=""
  
  if [ "$flags_array" = "" ]; then
    #config_dialog
    echo $CHECK_ON_CONFIG_MSG
    echo ""
    result=$($CLI_PATH/common/config_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name)
    config_found=$(echo "$result" | sed -n '1p')
    config_name=$(echo "$result" | sed -n '2p')
    multiple_configs=$(echo "$result" | sed -n '3p')
    config_index=$(echo "$result" | sed -n '5p')
    #check on config_name
    if [[ $config_name = "" ]]; then
        echo ""
        echo $CHECK_ON_CONFIG_ERR_MSG
        echo ""
        exit 1
    elif [[ $multiple_configs = "0" ]]; then
        echo $config_name
        #set config_index
        config_index="1"
        #echo ""
    fi
    echo ""
  else
    config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "$project_name" "$config_prefix" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $config_found = "0" ]]; then
        #echo ""
        echo $CHECK_ON_CONFIG_MSG
        echo ""
        result=$($CLI_PATH/common/config_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name)
        config_found=$(echo "$result" | sed -n '1p')
        config_name=$(echo "$result" | sed -n '2p')
        multiple_configs=$(echo "$result" | sed -n '3p')
        config_index=$(echo "$result" | sed -n '5p')
        if [[ $multiple_configs = "0" ]]; then
            echo $config_name
            #set config_index
            config_index="1"
        fi
        echo ""
    fi
  fi
}

config_check() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  local project_name=$5
  local config_prefix=$6
  shift 6
  local flags_array=("$@")
  result="$("$CLI_PATH/common/config_dialog_check" "${flags_array[@]}")"
  config_found=$(echo "$result" | sed -n '1p')
  config_index=$(echo "$result" | sed -n '2p')
  #config_name=$(echo "$result" | sed -n '3p')

  #get config name (we use the config_prefix as a parameter)
  config_string=$($CLI_PATH/common/get_config_string $config_index)
  config_name="$config_prefix$config_string"

  #forbidden combinations
  if [ "$project_name" = "" ]; then
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  elif [ "$config_found" = "1" ] && ([ "$config_index" = "" ] || [ "$config_index" = "0" ] || [ ! -e "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name/configs/$config_name" ]); then #implies that --project must be specified
      echo ""
      echo $CHECK_ON_CONFIG_ERR_MSG
      echo ""
      exit 1
  fi
}

cpu_check() {
  local CLI_PATH=$1
  local hostname=$2
  cpu_server=$($CLI_PATH/common/is_cpu $CLI_PATH $hostname)
  if [ "$cpu_server" = "0" ]; then
      echo ""
      echo $CHECK_ON_HOSTNAME_ERR_MSG
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

  if [[ $multiple_devices = "0" ]]; then
    device_found="1"
    device_index="1"
  else
    if [ "$flags_array" = "" ]; then
      #device_dialog
      echo $CHECK_ON_DEVICE_MSG
      echo ""
      result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
      device_found=$(echo "$result" | sed -n '1p')
      device_index=$(echo "$result" | sed -n '2p')
      echo ""
    else
      #forgotten mandatory
      device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
      if [[ $device_found = "0" ]]; then
        echo $CHECK_ON_DEVICE_MSG
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        echo ""
      fi
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
  if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && [ "$device_index" -ne 1 ]) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
      echo ""
      echo $CHECK_ON_DEVICE_ERR_MSG
      echo ""
      exit
  fi
}

driver_check() {
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  
  #driver_dialog_check
  result="$("$CLI_PATH/common/driver_dialog_check" "${flags_array[@]}")"
  driver_found=$(echo "$result" | sed -n '1p')
  driver_name=$(echo "$result" | sed -n '2p') 

  #forbidden combinations (1)
  if [ "$driver_found" = "0" ]; then
      program_driver_help
  fi

  #forbidden combinations (2 - if -r or --remove are present no other flags are allowed)
  remove_flag_found="0"

  for flag in "${flags_array[@]}"; do
    if [[ "$flag" == "-r" || "$flag" == "--remove" ]]; then
      remove_flag_found="1"
      break
    fi
  done

  if [ "$remove_flag_found" = "1" ]; then
    for flag in "${flags_array[@]}"; do
      if [[ "$flag" != "-r" && "$flag" != "--remove" && "$flag" == -* ]]; then
        program_driver_help
      fi
    done

    #get actual filename (i.e. onik.ko without the path)
    driver_name_base=$(basename "$driver_name")

    #forbidden combinations (3)
    if [ "$driver_found" = "1" ] && ([ "$driver_name_base" = "" ] || ! (lsmod | grep -q "${driver_name_base%.ko}" 2>/dev/null)); then
        echo ""
        echo $CHECK_ON_DRIVER_ERR_MSG
        echo ""
        exit 1
    fi
  else
    #forbidden combinations (3)
    if [ "$driver_found" = "1" ] && ([ "$driver_name" = "" ] || [ ! -f "$driver_name" ] || [ "${driver_name##*.}" != "ko" ]); then
        echo ""
        echo $CHECK_ON_DRIVER_ERR_MSG
        echo ""
        exit 1
    fi
    #params_dialog_check
    result="$("$CLI_PATH/common/params_dialog_check" "${flags_array[@]}")"
    params_found=$(echo "$result" | sed -n '1p')
    params_string=$(echo "$result" | sed -n '2p')

    #define the expected pattern for driver parameters
    pattern='^[^=,]+=[^=,]+(,[^=,]+=[^=,]+)*$' 

    #forbidden combinations (4)
    if [ "$params_found" = "1" ] && ([ "$params_string" = "" ] || ! [[ $params_string =~ $pattern ]]); then
        echo ""
        echo $CHECK_ON_DRIVER_PARAMS_ERR_MSG
        echo ""
        exit 1
    fi
  fi
}

fec_check() {
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  result="$("$CLI_PATH/common/fec_dialog_check" "${flags_array[@]}")"
  fec_option_found=$(echo "$result" | sed -n '1p')
  fec_option=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$fec_option_found" = "1" ] && { [ "$fec_option" -ne 0 ] && [ "$fec_option" -ne 1 ]; }; then
      echo ""
      echo $CHECK_ON_FEC_ERR_MSG
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
      echo $CHECK_ON_HOSTNAME_ERR_MSG
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

gpu_check() {
  local CLI_PATH=$1
  local hostname=$2
  gpu_server=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
  if [ "$gpu_server" = "0" ]; then
      echo ""
      echo $CHECK_ON_HOSTNAME_ERR_MSG
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
        echo ""
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
  local is_cpu=$3
  #local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  shift 3
  local flags_array=("$@")

  platform_found=""
  platform_name=""

  if [ "$is_cpu" = "0" ]; then
    platform_found="1"
    platform_name="none"
  else
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

  project_found="0"
  project_name=""

  #check on PWD
  project_path=$(dirname "$PWD")  

  if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
      project_found="1"
      project_name=$(basename "$PWD")
      return 1
  fi

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
      echo $CHECK_ON_HOSTNAME_ERR_MSG
      echo ""
      exit 1
  fi
}

sudo_check() {
  local username=$1
  is_sudo=$($CLI_PATH/common/is_sudo $username)
  if [ "$is_sudo" = "0" ]; then
    echo ""
    echo $CHECK_ON_SUDO_ERR_MSG
    echo ""
    exit 1
  fi
}

vivado_check() {
  local VIVADO_PATH=$1
  local vivado_version=$2
  if [ -z "$vivado_version" ] || [ ! -d $VIVADO_PATH/$vivado_version ]; then
    echo ""
    echo $CHECK_ON_VIVADO_ERR_MSG
    echo ""
    exit 1
  fi
}

vivado_developers_check() {
  local username=$1
  member=$($CLI_PATH/common/is_member $username vivado_developers)
  if [ "$member" = "0" ]; then
      echo ""
      echo $CHECK_ON_VIVADO_DEVELOPERS_ERR_MSG
      echo ""
      exit 1
  fi
}

xrt_check() {
  local CLI_PATH=$1
  #check on valid XRT and Vivado version
  xrt_version=$($CLI_PATH/common/get_xilinx_version xrt)
  if [ -z "$xrt_version" ]; then
      echo ""
      echo $CHECK_ON_XRT_ERR_MSG
      echo ""
      exit 1
  fi
}

xrt_shell_check() {
  local CLI_PATH=$1
  local device_index=$2
  SHELLS=("xilinx_u250_gen" "xilinx_u280_gen" "xilinx_u50_gen" "xilinx_u55c_gen" "xilinx_vck5000_gen")

  platform_name=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
  platform_name="${platform_name%%gen*}gen"

  #check if substring matches any array element
  match_found=false
  for shell in "${SHELLS[@]}"; do
    if [[ "$platform_name" == "$shell" ]]; then
        match_found=true
        break
    fi
  done

  if ! $match_found; then
    echo $CHECK_ON_XRT_SHELL_ERR_MSG
    echo ""
    exit 1
  fi
}

# build ------------------------------------------------------------------------------------------------------------------------

build_help() {
    is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
    is_cpu=$($CLI_PATH/common/is_cpu $CLI_PATH $hostname)
    is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
    is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
    $CLI_PATH/help/build $CLI_NAME $is_acap $is_cpu $is_fpga $is_gpu 
    exit
}

build_hip_help() {
    is_cpu=$($CLI_PATH/common/is_cpu $CLI_PATH $hostname)
    is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
    $CLI_PATH/help/build_hip $CLI_NAME $is_cpu $is_gpu
    exit
}

build_opennic_help() {
    is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
    is_cpu=$($CLI_PATH/common/is_cpu $CLI_PATH $hostname)
    is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
    $CLI_PATH/help/build_opennic $CLI_PATH $CLI_NAME $is_acap $is_cpu $is_fpga
    exit
}

# enable ------------------------------------------------------------------------------------------------------------------------

enable_help() {
  $CLI_PATH/help/enable $CLI_NAME $($CLI_PATH/common/is_cpu $CLI_PATH $hostname)
  exit
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
    $CLI_PATH/help/examine $CLI_NAME
    exit
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
    echo "   bdf             - Retreives FPGA Bus Device Function."
    echo "   clock           - Retreives FPGA Clock Information."
    echo "   memory          - Retreives FPGA Memory Information."
    echo "   name            - Retreives FPGA device names."
    echo "   network         - Retreives FPGA networking information."
    echo "   platform        - Retreives FPGA platform name."
    echo "   resource        - Retreives FPGA Resource Availability."
    echo "   serial          - Retreives FPGA serial numbers."
    echo "   slr             - Retreives FPGA Resource Availability and Memory Information per SLR."
    echo "   workflow        - Retreives FPGA current workflow."
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
    echo "Retreives FPGA Bus Device Function."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_clock_help() {
    echo ""
    echo "${bold}$CLI_NAME get clock [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA Clock Information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
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
    echo "Retreives FPGA Memory Information."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_name_help() {
    echo ""
    echo "${bold}$CLI_NAME get name [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA device names."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
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
  $CLI_PATH/help/get_network $CLI_PATH $CLI_NAME
  exit
}

get_platform_help() {
    echo ""
    echo "${bold}$CLI_NAME get platform [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA platform names."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_resource_help() {
    echo ""
    echo "${bold}$CLI_NAME get resource [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA Resource Availability."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_serial_help() {
    echo ""
    echo "${bold}$CLI_NAME get serial [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA serial numbers."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

get_slr_help() {
    echo ""
    echo "${bold}$CLI_NAME get slr [flags] [--help]${normal}"
    echo ""
    echo "Retreives FPGA Retreives FPGA Resource Availability and Memory Information per SLR."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
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
    echo "Retreives FPGA current workflow."
    echo ""
    echo "FLAGS:"
    echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
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
    echo "   hip             - Creates a new project using HIP Hello, world! template."
    echo "   opennic         - Creates a new project using OpenNIC Hello, world! template."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
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

new_opennic_help() {
    $CLI_PATH/help/new_opennic $CLI_PATH $CLI_NAME
    exit
}

# program ------------------------------------------------------------------------------------------------------------------------

program_help() {
    echo ""
    echo "${bold}$CLI_NAME program [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Download the acceleration program to a given FPGA."
    echo ""
    echo "ARGUMENTS:"
    echo "   driver          - Inserts a driver or module into the Linux kernel."
    echo "   opennic         - Programs OpenNIC to a given FPGA."
    echo "   reset           - Performs a 'HOT Reset' on a Vitis device."
    echo "   revert          - Returns a device to its default fabric setup."
    echo "   vivado          - Programs a Vivado bitstream to a given FPGA."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

program_driver_help() {
    $CLI_PATH/help/program_driver $CLI_NAME
    exit
}

program_opennic_help() {
    $CLI_PATH/help/program_opennic $CLI_PATH $CLI_NAME
    exit
}

program_reset_help() {
    $CLI_PATH/help/program_reset $CLI_NAME
    exit
}

program_revert_help() {
    $CLI_PATH/help/program_revert $CLI_NAME
    exit 
}

program_vivado_help() {
    $CLI_PATH/help/program_vivado $CLI_NAME
    exit
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
    echo "   opennic         - Runs OpenNIC on a given FPGA."
    echo ""
    echo "   hip             - Runs your HIP application on a given GPU."
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
    echo "   -d, --device    - GPU Device Index (according to $CLI_NAME examine)."
    echo "   -p, --project   - Specifies your HIP project name."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit 1
}

run_opennic_help() {
    $CLI_PATH/help/run_opennic $CLI_PATH $CLI_NAME
    exit
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

# update ------------------------------------------------------------------------------------------------------------------------

update_help() {
    #$CLI_PATH/help/update $CLI_NAME
    echo ""
    echo "${bold}$CLI_NAME update [--help]${normal}"
    echo ""
    echo "Updates $CLI_NAME to its latest version."
    echo ""
    echo "ARGUMENTS"
    echo "   This command has no arguments."
    echo ""
    echo "   -h, --help      - Help to use this command."
    echo ""
    exit
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
    echo ""
    echo "   opennic         - Validates OpenNIC on the selected FPGA."
    echo "   vitis           - Validates Vitis workflow on the selected FPGA."
    echo ""
    echo "   hip             - Validates HIP on the selected GPU." 
    echo "" 
    echo "   -h, --help      - Help to use this command."
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
      echo "   -d, --device    - GPU Device Index (according to $CLI_NAME examine)."
      echo ""
      echo "   -h, --help      - Help to use HIP validation."
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
      echo "Validates Vitis workflow on the selected FPGA."
      echo ""
      echo "FLAGS:"
      echo "   -d, --device    - Device Index (according to $CLI_NAME examine)."
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

#help 
if [ "$command_arguments_flags" = "$command $arguments -h " ]; then
  "${command}_${arguments}_help"
fi

#command and arguments switch
case "$command" in
  -h|--help)
    cli_help
    ;;
  -r|--release)
    cli_release
    ;;
  build)
    case "$arguments" in
      -h|--help)
        build_help
        ;;
      hip)
        #check on server (relates to sgutil_completion)
        if [ "$is_cpu" != "1" ] && [ "$is_gpu" != "1" ]; then
            exit 1
        fi

        valid_flags="-p --project -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        #check on server (relates to sgutil_completion)
        if [ "$is_acap" = "0" ] && [ "$is_cpu" = "0" ] && [ "$is_fpga" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit --platform --project -h --help" 
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks on command line
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          platform_check "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        fi

        #additional forbidden combination
        if [ "$is_cpu" = "0" ] && [ "$platform_found" = "1" ]; then
          build_opennic_help
        fi

        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID for shell: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        #we force the user to create a configuration
        if [ ! -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/device_config" ]; then
            #get current path
            current_path=$(pwd)
            cd "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name"
            echo "${bold}Adding device and host configurations with ./config_add:${normal}"
            ./config_add
            cd "$current_path"
        fi
        commit_name_driver=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/ONIC_DRIVER_COMMIT)
        platform_dialog "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "$is_cpu" "${flags_array[@]}"
        
        #run
        $CLI_PATH/build/opennic --commit $commit_name $commit_name_driver --platform $platform_name --project $project_name --version $vivado_version --all $is_cpu
        echo ""
        ;;
      *)
        build_help
      ;;  
    esac
    ;;
  enable)
    #check on server (relates to sgutil_completion)
    if [ "$is_cpu" = "0" ]; then
      exit 1
    fi

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
        valid_flags="-h --help -d --device -p --port"
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
    mkdir -p "$MY_PROJECTS_PATH/$arguments"
  
    case "$arguments" in
      -h|--help)
        new_help
        ;;
      hip)
        if [ "$#" -ne 2 ]; then
          new_hpi_help
          exit 1
        fi
        $CLI_PATH/new/hip
        ;;
      opennic)
        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        gh_check "$CLI_PATH"

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
            exists_shell=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_SHELL_REPO $commit_name_shell)
            exists_driver=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_DRIVER_REPO $commit_name_driver)

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

        #dialogs
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit IDs for shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
        echo ""
        new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
        push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
  
        #run
        $CLI_PATH/new/opennic --commit $commit_name_shell $commit_name_driver --project $new_name --push $push_option
        ;;
      *)
        new_help
      ;;
    esac
    ;;
  program)
    case "$arguments" in
      -h|--help)
        program_help
        ;;
      driver)
        #check on groups
        vivado_developers_check "$USER"

        #check on flags
        valid_flags="-i --insert -p --params -r --remove -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"
        
        #checks (command line)
        if [ "$flags_array" = "" ]; then
          program_driver_help
        fi

        #dialogs
        driver_check "$CLI_PATH" "${flags_array[@]}"
        #echo ""
        #echo "${bold}$CLI_NAME $command $arguments${normal}"
        #echo ""

        #check on -r or --remove
        if [ "$remove_flag_found" = "1" ]; then
          #get actual filename (i.e. onik.ko without the path)
          driver_name_base=$(basename "$driver_name")

          if lsmod | grep -q "${driver_name_base%.ko}"; then
            echo ""
            echo "${bold}$CLI_NAME $command $arguments${normal}"
            echo ""

            #change directory (this is important)
            cd $MY_DRIVERS_PATH
            
            #remove module
            echo "${bold}Removing ${driver_name_base%.ko} module:${normal}"
            echo ""
            echo "sudo rmmod ${driver_name_base%.ko}"
            echo ""
            sudo rmmod ${driver_name_base%.ko}

            echo "${bold}Deleting driver from $MY_DRIVERS_PATH:${normal}"
            echo ""
            echo "sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH"
            echo "sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/$driver_name.*"
            echo ""

            #change ownership to ensure writing permissions and remove
            sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH
            sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/$driver_name.*
          else
            echo ""
            echo $CHECK_ON_DRIVER_ERR_MSG
            echo ""
          fi
          exit
        fi

        echo ""
        echo "${bold}$CLI_NAME $command $arguments${normal}"
        echo ""

        #run
        $CLI_PATH/program/driver --insert $driver_name --params $params_string
        ;;
      opennic)
        #check on server
        virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"
      
        #check on flags
        valid_flags="-c --commit -d --device -p --project -r --remote -h --help"
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

        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        
        #bitstream check
        FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)
        bitstream_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
        if ! [ -e "$bitstream_path" ]; then
          echo "$CHECK_ON_BITSTREAM_ERR_MSG Please, use ${bold}$CLI_NAME build $arguments.${normal}"
          echo ""
          exit 1
        fi

        #driver check
        driver_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/$ONIC_DRIVER_NAME"
        if ! [ -e "$driver_path" ]; then
          echo "Your targeted driver is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
          echo ""
          exit 1
        fi

        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #run
        $CLI_PATH/program/opennic --commit $commit_name --device $device_index --project $project_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}" 
        ;;
      reset)
        #check on server
        virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on software  
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"

        #check on flags
        valid_flags="-d --device -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        fi

        xrt_check "$CLI_PATH"
        echo ""
        
        #dialogs
        echo "${bold}$CLI_NAME $command $arguments${normal}"
        echo ""
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        xrt_shell_check "$CLI_PATH" "$device_index"

        #run
        $CLI_PATH/program/reset --device $device_index --version $vivado_version
        ;;
      revert)
        #check on server
        virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on software  
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"

        #check on flags
        valid_flags="-d --device -v --version -h --help" # -v --version are not exposed and not shown in help command or completion
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #initialize
        device_found="0"
        device_index=""

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        fi
        
        #dialogs
        if [ "$multiple_devices" = "0" ]; then
          device_found="1"
          device_index="1"
          workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
          if [[ $workflow = "vitis" ]]; then
              exit
          fi
          echo ""
          echo "${bold}$CLI_NAME $command $arguments${normal}"
          echo ""
        elif [ "$device_found" = "0" ]; then   
          echo ""
          echo "${bold}$CLI_NAME $command $arguments${normal}"    
          echo ""
          device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
          if [[ $workflow = "vitis" ]]; then
              exit
          fi
        elif [ "$device_found" = "1" ]; then   
          workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
          if [[ $workflow = "vitis" ]]; then
              exit
          fi
          echo ""
          echo "${bold}$CLI_NAME $command $arguments${normal}"    
          echo ""
        fi
        
        #run
        $CLI_PATH/program/revert --device $device_index --version $vivado_version
        ;;
      vivado)
        #check on server
        virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on groups
        vivado_developers_check "$USER"

        #check on software  
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"

        #check on flags
        valid_flags="-b --bitstream -d --device -v --version -h --help" # -v --version are not exposed and not shown in help command or completion
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags" = "" ]; then
          #program_vivado_help
          echo ""
          echo "Your targeted bitstream and device are missing."
          echo ""
          exit
        else #if [ ! "$flags_array" = "" ]; then      
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          #bitstream_dialog_check
          result="$("$CLI_PATH/common/bitstream_dialog_check" "${flags_array[@]}")"
          bitstream_found=$(echo "$result" | sed -n '1p')
          bitstream_name=$(echo "$result" | sed -n '2p')
          #forbidden combinations (1/2)
          if [ "$bitstream_found" = "0" ] || ([ "$bitstream_found" = "1" ] && ([ "$bitstream_name" = "" ] || [ ! -f "$bitstream_name" ] || [ "${bitstream_name##*.}" != "bit" ])); then
              echo ""
              echo "Please, choose a valid bitstream name."
              echo ""
              exit
          fi
          #forbidden combinations (2/2)
          if [ "$multiple_devices" = "1" ] && [ "$bitstream_found" = "1" ] && [ "$device_found" = "0" ]; then # this means bitstream always needs --device when multiple_devices
              echo ""
              echo $CHECK_ON_DEVICE_ERR_MSG
              echo ""
              exit
          fi
          #device values when there is only a device
          if [[ $multiple_devices = "0" ]]; then
              device_found="1"
              device_index="1"
          fi
        fi
        echo ""

        #run
        $CLI_PATH/program/vivado --bitstream $bitstream_name --device $device_index --version $vivado_version
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
        #check on server (relates to cli_help)
        if [ "$is_sudo" != "1" ] && ! ([ "$is_cpu" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
          exit 1
        fi
        #fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        #sudo_check "$USER"
        #vivado_developers_check "$USER"
        #if [ "$is_sudo" = "0" ] || ([ "$is_cpu" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
        #  exit
        #fi


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
      hip) 
        #check on server
        gpu_check "$CLI_PATH" "$hostname"

        #check on flags
        valid_flags="-d --device -p --project -h --help" 
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        #check on server
        fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="--commit --config -d --device -p --project -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #constants
        CONFIG_PREFIX="host_config_"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
          config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "$project_name" "$CONFIG_PREFIX" "${flags_array[@]}"
        fi

        #early onic workflow check
        if [ "$device_found" = "1" ]; then
          workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
          if [ ! "$workflow" = "opennic" ]; then
              echo ""
              echo "$CHECK_ON_WORKFLOW_ERR_MSG"
              echo ""
              exit
          fi
        fi
        
        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        config_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "$project_name" "$CONFIG_PREFIX" "${flags_array[@]}"
        if [ "$project_found" = "1" ] && [ ! -e "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/$config_name" ]; then
            echo ""
            echo "$CHECK_ON_CONFIG_ERR_MSG"
            echo ""
            exit
        fi
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"

        #onic workflow check
        workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
        if [ ! "$workflow" = "opennic" ]; then
            echo "$CHECK_ON_WORKFLOW_ERR_MSG"
            echo ""
            exit
        fi

        #onic application check
        if [ ! -x "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/onic" ]; then
          echo "Your targeted application is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
          echo ""
          exit 1
        fi

        #run
        $CLI_PATH/run/opennic --commit $commit_name --config $config_index --device $device_index --project $project_name 
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
      *)
        set_help
      ;;  
    esac
    ;;
  update)
    case "$arguments" in
      -h|--help)
        update_help
        ;;
      *)
        if [ "$#" -ne 1 ]; then
          update_help
          exit 1
        fi
        sudo_check $USER

        #get update.sh
        cd $UPDATES_PATH
        git clone $REPO_URL > /dev/null 2>&1 #https://github.com/fpgasystems/sgrt.git

        #copy update
        sudo mv $UPDATES_PATH/$REPO_NAME/update.sh $SGRT_PATH/update
        
        #remove temporal copy
        rm -rf $UPDATES_PATH/$REPO_NAME
        
        #run up to date update 
        $SGRT_PATH/update
        ;;
    esac
    ;;
  validate)
    #create workflow directory
    mkdir -p "$MY_PROJECTS_PATH/$arguments"

    case "$arguments" in
      docker)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      hip)
        valid_flags="-d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        #check on server
        virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on groups
        vivado_developers_check "$USER"

        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit -d --device -f --fec -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line 1/2 - check_on_commits)
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
        else
            #commit_dialog_check
            result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
            commit_found=$(echo "$result" | sed -n '1p')
            commit_name=$(echo "$result" | sed -n '2p')

            #check if commit_name contains exactly one comma
            if [ "$commit_found" = "1" ] && { [ "$commit_name" = "" ] || ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; }; then #if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
                echo ""
                echo "Please, choose valid shell and driver commit IDs."
                echo ""
                exit
            fi
            
            #get shell and driver commits (shell_commit,driver_commit)
            commit_name_shell=${commit_name%%,*}
            commit_name_driver=${commit_name#*,}

            #check if commits exist
            exists_shell=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_SHELL_REPO $commit_name_shell)
            exists_driver=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_DRIVER_REPO $commit_name_driver)

            if [ "$commit_found" = "0" ]; then 
                commit_name_shell=$ONIC_SHELL_COMMIT
                commit_name_driver=$ONIC_DRIVER_COMMIT
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$exists_shell" = "0" ]); then
                echo ""
                echo "Please, choose a valid shell commit ID." # similar to CHECK_ON_COMMIT_ERR_MSG
                echo ""
                exit 1
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_driver" = "" ] || [ "$exists_driver" = "0" ]); then
                echo ""
                echo "Please, choose a valid driver commit ID." # similar to CHECK_ON_COMMIT_ERR_MSG
                echo ""
                exit 1
            fi
        fi
        #echo ""

        #initialize
        device_found="0"
        device_index=""
        fec_option_found="0"
        fec_option=""

        #checks (command line 2/2)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          fec_check "$CLI_PATH" "${flags_array[@]}"
        fi

        if [ "$multiple_devices" = "0" ]; then
          device_found="1"
          device_index="1"
          echo ""
          echo "${bold}$CLI_NAME $command $arguments (shell and driver commit IDs: $commit_name_shell,$commit_name_driver)${normal}"
          echo ""
        else
          echo ""
          echo "${bold}$CLI_NAME $command $arguments (shell and driver commit IDs: $commit_name_shell,$commit_name_driver)${normal}"
          echo ""
          device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        fi

        #bitstream check (the bitstream must be pre-compiled for validation)
        FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)
        bitstream_path="$BITSTREAMS_PATH/$arguments/$commit_name_shell/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
        if ! [ -e "$bitstream_path" ]; then
          echo "$CHECK_ON_BITSTREAM_ERR_MSG"
          echo ""
          exit 1
        fi

        #dialogs
        if [ "$fec_option_found" = "0" ]; then
          echo "${bold}Please, choose your encoding scheme:${normal}"
          echo ""
          echo "0) RS_FEC_ENABLED = 0"
          echo "1) RS_FEC_ENABLED = 1"
          while true; do
              read -p "" choice
              case $choice in
                  "0")
                      fec_option="0"
                      break
                      ;;
                  "1")
                      fec_option="1"
                      break
                      ;;
              esac
          done
          echo ""
        fi

        #run
        $CLI_PATH/validate/opennic --commit $commit_name_shell $commit_name_driver --device $device_index --fec $fec_option --version $vivado_version
        ;;
      vitis)
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
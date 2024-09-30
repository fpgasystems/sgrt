#!/bin/bash

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_network"

#constants (id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC)
ID_COLUMN=1
BDF_COLUMN=2
DEVICE_TYPE_COLUMN=3
DEVICE_NAME_COLUMN=4
IP_COLUMN=5
MAC_COLUMN=6

#inputs (./examine 0 root_port)
device_index=$1
parameter=$2

#helper functions
get_column() {
  parameter=$1
  case "$parameter" in
    # id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC  
    id)
      column=$ID_COLUMN
      ;;
    bdf)
      column=$BDF_COLUMN
      ;;
    device_type)
      column=$DEVICE_TYPE_COLUMN
      ;;
    device_name)
      column=$DEVICE_NAME_COLUMN
      ;;
    IP)
      column=$IP_COLUMN
      ;;
    MAC)
      column=$MAC_COLUMN
      ;;
    *)
      echo "Unknown parameter $parameter."
      ;;
  esac
  echo $column
}

if [[ -f "$DEVICES_LIST" ]]; then
  #print if the first fpga/acap is valid
  device_1=$(head -n 1 "$DEVICES_LIST")
  bdf=$(echo "$device_1" | awk '{print $2}')

  if [[ -n "$(lspci | grep $bdf)" ]]; then
    #get column for the parameter
    parameter_column=$(get_column $parameter)
    #output device parameter
    awk -v device_index="$device_index" -v parameter_column="$parameter_column" '$1 == device_index {print $parameter_column}' $DEVICES_LIST
  fi
fi
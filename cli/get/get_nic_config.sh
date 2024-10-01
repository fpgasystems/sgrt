#!/bin/bash

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_network"

#constants (id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC)
#ID_COLUMN=1
#BDF_COLUMN=2
#DEVICE_TYPE_COLUMN=3
#DEVICE_NAME_COLUMN=4
#IP_COLUMN=5
#MAC_COLUMN=6

#inputs (./examine 0 root_port)
device_index=$1
parameter=$2

#get device IP
IP=$($CLI_PATH/get/get_nic_device_param $device_index IP)

#get device MAC
MAC=$($CLI_PATH/get/get_nic_device_param $device_index MAC)

case "$parameter" in
    # id upstream_port root_port LinkCtl device_type device_name serial_number IP MAC  
    DEVICE)
      echo $IP
      ;;
    STATE)
      echo $MAC
      ;;
    *)
      echo "Unknown parameter $parameter."
      ;;
  esac
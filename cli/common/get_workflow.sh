#!/bin/bash

CLI_PATH=$1
device_index=$3

$CLI_PATH/get/workflow -d $device_index | cut -d':' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v '^$'
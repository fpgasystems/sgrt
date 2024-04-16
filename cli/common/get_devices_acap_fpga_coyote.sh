#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
TMP_PATH="/tmp"

#copy to tmp
cp -f $DEVICES_LIST $TMP_PATH/devices_acap_fpga

#remove all columns except first and second
awk '{print $1, $2}' $TMP_PATH/devices_acap_fpga > $TMP_PATH/devices_acap_fpga_coyote

#remove function (everything after .)
sed -i 's/\..*//g' "$TMP_PATH/devices_acap_fpga_coyote"

#replace ":" with a blank space
sed -i 's/:/ /g; s/\.[^.]*$//' "$TMP_PATH/devices_acap_fpga_coyote"

#insert an equal
sed -i 's/:/ /g; s/\..*//; s/  */ = /' "$TMP_PATH/devices_acap_fpga_coyote"

#insert a line return at the end
sed -i -e '${/^$/!G}' "$TMP_PATH/devices_acap_fpga_coyote"

#copy file to CLI_PATH (if it does not exists or if the files are different)
if [ ! -f "$CLI_PATH/devices_acap_fpga_coyote" ] || ! cmp -s "$TMP_PATH/devices_acap_fpga_coyote" "$CLI_PATH/devices_acap_fpga_coyote"; then
    sudo cp -f "$TMP_PATH/devices_acap_fpga_coyote" "$CLI_PATH/devices_acap_fpga_coyote"
fi
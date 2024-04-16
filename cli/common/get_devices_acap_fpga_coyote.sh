#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$(dirname "$0")")"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
#TMP_PATH="/tmp"

#copy to tmp
#cp -f $DEVICES_LIST $TMP_PATH/devices_acap_fpga
sudo cp -f $DEVICES_LIST ${DEVICES_LIST}_coyote

#remove all columns except first and second
#awk '{print $1, $2}' $TMP_PATH/devices_acap_fpga > $TMP_PATH/devices_acap_fpga_coyote
sudo sed -i 's/^\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\).*/\1 \2/' "${DEVICES_LIST}_coyote"

#awk '{print $1, $2}' $DEVICES_LIST > ${DEVICES_LIST}_coyote

#remove function (everything after .)
#sed -i 's/\..*//g' "$TMP_PATH/devices_acap_fpga_coyote"
sudo sed -i 's/\..*//g' "${DEVICES_LIST}_coyote"

#replace ":" with a blank space
#sed -i 's/:/ /g; s/\.[^.]*$//' "$TMP_PATH/devices_acap_fpga_coyote"
sudo sed -i 's/:/ /g; s/\.[^.]*$//' "${DEVICES_LIST}_coyote"

#insert an equal
#sed -i 's/:/ /g; s/\..*//; s/  */ = /' "$TMP_PATH/devices_acap_fpga_coyote"
sudo sed -i 's/:/ /g; s/\..*//; s/  */ = /' "${DEVICES_LIST}_coyote"

#insert a line return at the end
#sed -i -e '${/^$/!G}' "$TMP_PATH/devices_acap_fpga_coyote"
sudo sed -i -e '${/^$/!G}' "${DEVICES_LIST}_coyote"

#copy file to CLI_PATH (if it does not exists or if the files are different)
#if [ ! -f "$CLI_PATH/devices_acap_fpga_coyote" ] || ! cmp -s "$TMP_PATH/devices_acap_fpga_coyote" "$CLI_PATH/devices_acap_fpga_coyote"; then
#    sudo cp -f "$TMP_PATH/devices_acap_fpga_coyote" "$CLI_PATH/devices_acap_fpga_coyote"
#fi
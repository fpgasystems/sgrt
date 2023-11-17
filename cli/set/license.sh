#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
LM_LICENSE_FILE=$($CLI_PATH/common/get_constant $CLI_PATH LM_LICENSE_FILE) # CLI_PATH is declared as an environment variable
XILINXD_LICENSE_FILE=$($CLI_PATH/common/get_constant $CLI_PATH XILINXD_LICENSE_FILE)

export LM_LICENSE_FILE=$LM_LICENSE_FILE
export XILINXD_LICENSE_FILE=$XILINXD_LICENSE_FILE
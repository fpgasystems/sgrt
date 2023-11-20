#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

# Specify list of servers
file_path="$CLI_PATH/constants/XILINXD_LICENSE_FILE"

# Read the lines from the file into an array
mapfile -t lines < "$file_path"

# Join the array elements with ':' to create the desired format
XILINXD_LICENSE_FILE=$(IFS=:; echo "${lines[*]}")

# Print the result or use it as needed
export XILINXD_LICENSE_FILE
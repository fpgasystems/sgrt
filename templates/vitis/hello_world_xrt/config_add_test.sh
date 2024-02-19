#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
MY_PROJECT_PATH="$(dirname "$(dirname "$0")")"
#TEMPLATE="vadd"

#change to project directory
cd $MY_PROJECT_PATH

#read from parameters
declare -a parameters
declare -a descriptions
declare -a ranges

while read -r line; do
    column_1=$(echo "$line" | awk '{print $1}')
    column_2=$(echo "$line" | awk '{print $2}')
    column_3=$(echo "$line" | awk '{print $3}')
    parameters+=("$column_1")
    ranges+=("$column_2")
    descriptions+=("$column_3")
done < "parameters"

for ((i = 0; i < ${#parameters[@]}; i++)); do
    # Map to parameters
    parameter_i="${parameters[i]}"
    ranges_i="${ranges[i]}"

    min=""
    inc=""
    max=""
    case "$ranges_i" in
        *:*)
            colon_count=$(grep -o ":" <<< "$ranges_i" | wc -l)
            if [[ $colon_count -eq 1 ]]; then
                echo "The $parameter_i contains a single colon (:)"
                min="${ranges_i%%:*}"   # Get the part before the first colon
                max="${ranges_i#*:}"    # Get the part after the first colon
                echo "min = $min"
                echo "max = $max"
            elif [[ $colon_count -eq 2 ]]; then
                echo "The $parameter_i contains two colons (:)"
                min="${ranges_i%%:*}"          # Get the part before the first colon
                remaining="${ranges_i#*:}"     # Remove the part before the first colon
                inc="${remaining%%:*}"       # Get the part between the first and second colons
                max="${remaining#*:}"        # Get the part after the second colon
                echo "min = $min"
                echo "inc = $inc"
                echo "max = $max"
            fi
            ;;
        *","*)
            echo "The $parameter_i contains one or more single quotes (,)"
            ;;
        *)
            echo "The $parameter_i is a string without any colon (:), comma (,), or any other specified character"
            ;;
    esac
done
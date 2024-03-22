#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

nk_file=$1
sp_file=$2
output_dir=${3%/}  # Remove trailing slash if present

#read from nk
declare -a xclbin_names
declare -a compute_units_num
declare -a compute_units_names

while read -r line; do
    column_1=$(echo "$line" | awk '{print $1}')
    column_2=$(echo "$line" | awk '{print $2}')
    column_3=$(echo "$line" | awk '{print $3}')
    xclbin_names+=("$column_1")
    compute_units_num+=("$column_2")
    compute_units_names+=("$column_3")
done < "$nk_file"

#read from sp to create sp_aux (to append later)
touch $output_dir/sp_aux
while read -r line; do
    # Extract second column (e.g., "vadd")
    operation=$(echo "$line" | awk '{print $2}')
    # Extract other columns except the first two
    columns=$(echo "$line" | awk '{$1=""; $2=""; print $0}')
    # Split the columns based on whitespace and iterate over them
    for col in $columns; do
        # Construct and print the desired output
        echo "sp=$operation.$col" >> $output_dir/sp_aux
    done
done < "$sp_file"

for ((i = 0; i < ${#xclbin_names[@]}; i++)); do

    #map to nk
    xclbin_i="${xclbin_names[i]}"
    compute_units_num_i="${compute_units_num[i]}"
    compute_units_names_i="${compute_units_names[i]}"

    #delete first
    if [ -f "$output_dir/$xclbin_i.cfg" ]; then
        rm $output_dir/$xclbin_i.cfg
    fi
    
    #create <xclbin.cfg>
    touch $output_dir/$xclbin_i.cfg
    echo "[connectivity]" >> $output_dir/$xclbin_i.cfg

    #nk
    if [ "$compute_units_names_i" = "" ]; then
        echo "nk=$xclbin_i:$compute_units_num_i" >> $output_dir/$xclbin_i.cfg 
    else
        echo "nk=$xclbin_i:$compute_units_num_i:$compute_units_names_i" >> $output_dir/$xclbin_i.cfg 
    fi

    echo >> $output_dir/$xclbin_i.cfg

    #sp
    grep "sp=$xclbin_i" $output_dir/sp_aux >> $output_dir/$xclbin_i.cfg


done

#remove sp_aux
if [ -f "$output_dir/sp_aux" ]; then
    rm "$output_dir/sp_aux"
fi

#return xclbin_names
echo "${xclbin_names[@]}"
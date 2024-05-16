#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#nk_file=$1
sp_file=$1
output_dir=${2%/}  # Remove trailing slash if present

#read from nk
#declare -a xclbin_names
#declare -a compute_units_num
#declare -a compute_units_names

#while read -r line; do
#    column_1=$(echo "$line" | awk '{print $1}')
#    #column_2=$(echo "$line" | awk '{print $2}')
#    column_2=$(echo "$line" | awk '{print $2}')
#    xclbin_names+=("$column_1")
#    #compute_units_num+=("$column_2")
#    compute_units_names+=("$column_2")
#done < "$nk_file"

#compute_units_num=()
#for unit_name in "${compute_units_names[@]}"; do
#    count=$(echo "$unit_name" | tr -cd ',' | wc -c)
#    count=$((count + 1))
#    compute_units_num+=("$count")
#    #echo "$unit_name has $count units"
#done

# Declare arrays
declare -a device_indexes
declare -a xclbin_names
declare -a compute_units_names

# Read file and populate arrays
while read -r line; do
    # Check if the line starts with a digit (device index)
    if [[ $line =~ ^[0-9]+ ]]; then
        current_index=$(echo "$line" | awk '{print $1}')
        current_xclbin=$(echo "$line" | awk '{print $2}')
        compute_unit=$(echo "$line" | awk '{print $3}')
        
        # Add to arrays
        device_indexes+=("$current_index")
        xclbin_names+=("$current_xclbin")
        compute_units_names+=("$compute_unit")
    else
        compute_unit=$(echo "$line" | awk '{print $1}')
        
        # Update the last compute unit entry
        compute_units_names[-1]="${compute_units_names[-1]},$compute_unit"
    fi
done < "$sp_file"

compute_units_num=()
for unit_name in "${compute_units_names[@]}"; do
    count=$(echo "$unit_name" | tr -cd ',' | wc -c)
    count=$((count + 1))
    compute_units_num+=("$count")
done

# Print contents of arrays for verification
#echo "Device Indexes: ${device_indexes[@]}"
#echo "XCLBIN Names: ${xclbin_names[@]}"
#echo "Compute Units num: ${compute_units_num[@]}"
#echo "Compute Units Names: ${compute_units_names[@]}"

#echo "nou"
#for unit_name in "${compute_units_num_aux[@]}"; do
#    echo "$unit_name"
#done

#echo "HEY!!"
#exit

#read from sp to create sp_aux (to append later)
#touch $output_dir/sp_aux
#while read -r line; do
#    # Extract second column (e.g., "vadd")
#    operation=$(echo "$line" | awk '{print $2}')
#    # Extract other columns except the first two
#    columns=$(echo "$line" | awk '{$1=""; $2=""; print $0}')
#    # Split the columns based on whitespace and iterate over them
#    for col in $columns; do
#        # Construct and print the desired output
#        echo "sp=$operation.$col" >> $output_dir/sp_aux
#    done
#done < "$sp_file"

for ((i = 0; i < ${#xclbin_names[@]}; i++)); do

    #map to nk
    xclbin_name_i="${xclbin_names[i]}"
    compute_units_num_i="${compute_units_num[i]}"
    compute_units_names_i="${compute_units_names[i]}"

    #delete first
    if [ -f "$output_dir/$xclbin_name_i.cfg" ]; then
        rm -f "$output_dir/$xclbin_name_i.cfg"
    fi
    
    #create <xclbin.cfg>
    touch "$output_dir/$xclbin_name_i.cfg"
    echo "[connectivity]" >> "$output_dir/$xclbin_name_i.cfg"

    #nk
    if [ -z "$compute_units_names_i" ]; then
        echo "nk=$xclbin_name_i:$compute_units_num_i" >> "$output_dir/$xclbin_name_i.cfg"
    else
        echo "nk=$xclbin_name_i:$compute_units_num_i:$compute_units_names_i" >> "$output_dir/$xclbin_name_i.cfg"
    fi

    #sp
    # Set the IFS to comma to split the string
    IFS=','
    # Read the comma-separated values into an array
    read -ra kernel_names <<< "$compute_units_names_i"
    # Iterate over the elements of the array
    for kernel_name in "${kernel_names[@]}"; do
        # Process each element (kernel name) here
        echo "$kernel_name"

        #matching kernel_name can be in columns $3 (with device_index) or $1 (without device_index)
        kernel_arguments=$(awk -v kn="$kernel_name" '$3 == kn || $1 == kn' "$sp_file" | sed "s/.*$kernel_name[[:space:]]*//")

        echo "$kernel_arguments"

        # Split kernel_arguments into individual fields
        IFS=' ' read -ra columns <<< "$kernel_arguments"
        
        # Iterate over each column and append to the config file
        for column in "${columns[@]}"; do
            echo "sp=$kernel_name.$column" >> "$output_dir/$xclbin_name_i.cfg"
        done

    done
    


    #if [ -n "$compute_units_names_i" ]; then
    #    IFS=',' read -ra kernel_names <<< "$compute_units_names_i"
    #    # Iterate over the elements of the array
    #    for kernel_names_i in "${kernel_names[@]}"; do
    #        # Search for the matching line in the input file
    #        match=$(grep "$kernel_names_i" "$sp_file")
    #
    #        # If a match is found, construct and print the desired output
    #        if [[ -n "$match" ]]; then
    #            # Extract columns starting from the fourth column (in1)
    #            columns=$(echo "$match" | awk '{$1=$2=$3=""; print $0}')
    #
    #            # Iterate over each column
    #            while IFS= read -r column; do
    #                # Construct and print the output
    #                echo "sp=$kernel_names_i.$column"
    #            done <<< "$columns"
    #        fi
    #    done
    #fi

done

#remove sp_aux
#if [ -f "$output_dir/sp_aux" ]; then
#    rm "$output_dir/sp_aux"
#fi

#return xclbin_names
echo "${xclbin_names[@]}"
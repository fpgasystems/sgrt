#!/bin/bash

#username=$1
#workflow=$2

MY_PROJECT_PATH=$1

# Declare global variables
declare -g xclbin_found="0"
declare -g xclbin_name=""
declare -g multiple_xclbins="0"

#get xclbins
cd $MY_PROJECT_PATH/src/xclbin
#echo $MY_PROJECT_PATH/src/xclbin
#echo $pwd
xclbins=( *".cpp" )

#delete ".cpp" from xclbins
j=0
for i in "${xclbins[@]}"
do
    #if [[ $i =~ "common/" ]]; then
    #    echo "" >&/dev/null
    #else
        aux[j]=${i::-4}
        j=$(($j + 1))
    #fi
done

# Check if there is only one directory
if [ ${#aux[@]} -eq 1 ]; then
    xclbin_found="1"
    xclbin_name=${aux[0]}
    #xclbin_name=${xclbin_name::-4} # remove the last characters, i.e. ".cpp"
else
    multiple_xclbins="1"
    PS3=""
    select xclbin_name in "${aux[@]}"; do
        if [[ -z $xclbin_name ]]; then
            echo "" >&/dev/null
        else
            xclbin_found="1"
            #xclbin_name=${xclbin_name::-4} # remove the last characters, i.e. ".cpp"
            break
        fi
    done
fi

# Return the values of xclbin_found and xclbin_name
echo "$xclbin_found"
echo "$xclbin_name"
echo "$multiple_xclbins"
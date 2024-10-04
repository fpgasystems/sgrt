#!/bin/bash

workflow=$1
is_acap=$2
#is_build=$3
is_fpga=$3
is_gpu=$4
is_gpu_developer=$5
is_vivado_developer=$6

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#integrations
gpu_enabled="0"
vivado_enabled="0"

#return
if [ "$workflow" = "gpu" ]; then
    #gpu
    #gpu_enabled=$([ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
    if [ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ]; then 
        gpu_enabled="1"
    fi
    echo "$gpu_enabled"
elif [ "$workflow" = "vivado" ]; then
    #vivado
    #vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
    if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; }; then 
        vivado_enabled="1"
    fi
    echo "$vivado_enabled"
fi
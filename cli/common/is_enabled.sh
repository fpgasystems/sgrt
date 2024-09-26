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
#vitis_integrations="0"

#return
if [ "$workflow" = "gpu" ]; then
    #gpu
    #if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
    if [ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ]; then #[ "$is_build" = "1" ] || 
        gpu_enabled="1"
    fi
    echo "$gpu_enabled"
elif [ "$workflow" = "vivado" ]; then
    #vivado
    if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; }; then #[ "$is_build" = "1" ] ||
        vivado_enabled="1"
    fi
    echo "$vivado_enabled"
#elif [ "$workflow" = "vitis" ]; then
#    #if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
#    if [ "$is_vitis_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; }; then
#        vitis_integrations="1"
#    fi
#    echo $vitis_integrations
fi
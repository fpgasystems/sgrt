#!/bin/bash

workflow=$1
is_acap=$2
is_build=$3
is_fpga=$4
is_gpu=$5
is_vivado_developer=$6

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#integrations
gpu_integrations="0"
vivado_integrations="0"
vitis_integrations="0"

#return
if [ "$workflow" = "build_gpu" ]; then
    #gpu
    if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
        gpu_integrations="1"
    fi
    echo "$gpu_integrations"
elif [ "$workflow" = "build_vivado" ]; then
    #vivado
    if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
        vivado_integrations="1"
    fi
    echo "$vivado_integrations"
elif [ "$workflow" = "build_vitis" ]; then
    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
        vitis_integrations="1"
    fi
    echo $vitis_integrations
fi
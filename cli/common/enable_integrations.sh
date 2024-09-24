#!/bin/bash

workflow=$1
is_acap=$2
is_build=$3
is_fpga=$4
is_gpu=$5
is_vivado_developer=$6

#integrations
gpu_integrations="0"
vivado_integrations="0"

#return
if [ "$workflow" = "gpu" ]; then
    #gpu
    if [ "$is_build" = "1" ] || [ "$is_gpu" = "1" ]; then
        gpu_integrations="1"
    fi
    echo "$gpu_integrations"
elif [ "$workflow" = "vivado" ]; then
    #vivado
    if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
        vivado_integrations="1"
    fi
    echo "$vivado_integrations"
fi
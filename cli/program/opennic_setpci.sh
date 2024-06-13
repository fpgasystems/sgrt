#!/bin/bash

upstream_port=$1
command=$2

eval "setpci -s $upstream_port $command"
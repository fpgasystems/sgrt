#!/bin/bash

upstream_port=$1
command=$2

sudo setpci -s $upstream_port $command
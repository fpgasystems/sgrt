#!/bin/bash

eno_onic=$1
IP0=$2
netmask=$3

sudo ifconfig $eno_onic down
sudo ifconfig $eno_onic $IP0 netmask $netmask
sudo ifconfig $eno_onic up
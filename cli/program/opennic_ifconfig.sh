#!/bin/bash

eno_onic=$1
IP0=$2
cidr=$3

sudo ifconfig $eno_onic $IP0/$cidr up
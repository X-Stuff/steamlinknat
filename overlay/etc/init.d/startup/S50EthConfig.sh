#!/bin/sh

# Desired static IP on eth0
# This IP should be set up as default gateway
STEAMLINK_IP=192.168.0.110

ifconfig eth0 $STEAMLINK_IP netmask 255.255.255.0

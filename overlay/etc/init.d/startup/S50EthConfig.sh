#!/bin/sh

# Desired static IP on eth0
# This IP should be set up as default gateway
STEAMLINK_IP=192.168.0.110

ifconfig eth0 $STEAMLINK_IP netmask 255.255.255.0

# Replacing "router" IP
sed -i "s/opt\s*router\s*.*$/opt\trouter\t$STEAMLINK_IP/g" /etc/udhcpd.conf

# launching DHCP server in eth0 interface (in order to get bridge also working)
udhcpd /etc/udhcpd.conf
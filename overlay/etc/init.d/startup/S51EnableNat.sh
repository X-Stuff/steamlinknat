#!/bin/sh

# Loading kernel modules explicitly. Otherwise nothing is working.
modprobe nf_conntrack_ipv4
modprobe iptable_nat
modprobe ipt_MASQUERADE
modprobe ip_tables

# Enabling forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Forwarding packets from Ethernet to WiFi
# Using custom MUSL built iptables with all extensions compiled statically 
/usr/local/sbin/xtables-multi-armv7-static iptables -t nat -A POSTROUTING -o mlan0 -j MASQUERADE

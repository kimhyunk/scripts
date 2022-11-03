#!/bin/bash

# Echo commands and abort on errors
set -e

# Define network interfaces:
IFACE_WAN=enp216s0
IFACE_LAN0=eno1

# Clean
# iptables -P chain target [options]
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -t nat -F

# Do masquerade
iptables -A FORWARD -i $IFACE_WAN -o $IFACE_LAN0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $IFACE_LAN0 -o $IFACE_WAN -j ACCEPT


iptables -t nat -A POSTROUTING -o $IFACE_WAN -j MASQUERADE
# Allow DHCP and DNS requests from LAN

iptables -A INPUT -p udp -i $IFACE_LAN0 --dport 67 -j ACCEPT
iptables -A INPUT -p udp -i $IFACE_LAN0 --dport 53 -j ACCEPT

iptables -A INPUT -p tcp -s 192.168.10.29 --dport 17001 -j ACCEPT
iptables -A OUTPUT -p tcp -s 192.168.10.29 --dport 17001 -j ACCEPT


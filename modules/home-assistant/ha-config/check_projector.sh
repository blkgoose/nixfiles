#!/bin/sh
# Get IP from ARP table by MAC, then ping it
IP=$(awk -v mac="58:41:46:6d:4f:a1" 'tolower($4) == mac {print $1}' /proc/net/arp)
if [ -n "$IP" ] && ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
  echo "ON"
else
  echo "OFF"
fi

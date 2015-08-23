#!/bin/sh
set -e
set -x
echo j | ufw reset
ufw default deny incoming
ufw default deny outgoing
# DNS
ufw allow in proto udp from any port 53
ufw allow out proto udp to any port 53
ufw allow in proto tcp from any port 53
ufw allow out proto tcp to any port 53
# DHCP
ufw allow in proto udp from any port 67
ufw allow out proto udp to any port 67
ufw allow in proto udp from any port 68
ufw allow out proto udp to any port 68
# local stuff
ufw allow in proto tcp from 192.168.19.0/24 
ufw allow out proto tcp to 192.168.19.0/24 
# smarterbalanced
ufw allow in proto tcp from 23.253.30.0/24 
ufw allow out proto tcp to 23.253.30.0/24 
ufw allow in proto tcp from 23.253.30.24
ufw allow out proto tcp to 23.253.30.24
# khan
ufw allow in proto tcp from 54.231.0.0/16
ufw allow out proto tcp to 54.231.0.0/16

# Loop in case of round robin (flaky, but what else to do?)
for i in 1
do
    # payload
    for block in `sh whitelist.sh`
    do
        ufw allow in proto tcp from $block
        ufw allow out proto tcp to $block
    done
done
ufw enable
ufw status

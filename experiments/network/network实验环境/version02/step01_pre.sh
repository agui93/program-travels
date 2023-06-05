#!/bin/bash
#################################################################
##
## 关闭UFW: Uncomplicated Firewall是ubuntu自带的防火墙
## 开启主机ipv4的转发功能
##
#################################################################

echo "stop ufw and disable ufw"
systemctl stop ufw
systemctl disable ufw


echo "iptables: ipv4 ip_forward allowed"
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -p
/sbin/iptables -P FORWARD ACCEPT



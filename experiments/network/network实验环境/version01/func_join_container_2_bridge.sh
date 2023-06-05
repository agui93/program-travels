#!/bin/bash
################################################################# 
##  已知: 
##    容器: 未配置网卡和路由; 看作是完全独立的机器
##    bridge: 也叫做switch, 使用openvswitch创建的虚拟交换机; 看作是一台交换机, 等价为一个二层网络(即数据链路层)
##
##  目标: 
##    把容器接入到bridge; 可以看作把一台机器接入到二层网络
##  
##  方法: 
##    使用veth连接主机和容器
##    其中, veth的一端配置在主机switch的port
##    其中, veth的另一端配置在容器内的网卡
################################################################# 

set -e

# BRIDGE_IFNAME是二层网络, CONTAINER_NAME是容器名称, CONTAINER_CIDR_IPADDR是容器网卡的地址(cidr)
BRIDGE_IFNAME=$1    
CONTAINER_NAME=$2
CONTAINER_CIDR_IPADDR=$3


# MTU是最大传输单元, NSPID是容器的网络namespace
MTU=$(ip link show "$BRIDGE_IFNAME" | awk '{print $5}')
NSPID=$(docker inspect --format='{{ .State.Pid }}' "$CONTAINER_NAME")
[ ! -d /var/run/netns ] && mkdir -p /var/run/netns
rm -f "/var/run/netns/$NSPID"
ln -s "/proc/$NSPID/ns/net" "/var/run/netns/$NSPID"


# 添加veth, 配置目标: 把${LOCAL_IFNAME}安装在主机的网络空间中, 把${GUEST_IFNAME}安装在容器的网络空间中
LOCAL_IFNAME="veth1pl${NSPID}"
GUEST_IFNAME="veth1pg${NSPID}"
ip link add name "$LOCAL_IFNAME" mtu "$MTU" type veth peer name "$GUEST_IFNAME" mtu "$MTU"


# 把${LOCAL_IFNAME}安装在主机的网络空间
## 虚机交换机中添加port: 把veth的${LOCAL_IFNAME}端接入vswitch
ovs-vsctl add-port "$BRIDGE_IFNAME" "$LOCAL_IFNAME"
ip link set "$LOCAL_IFNAME" up


# 把${GUEST_IFNAME}安装在容器的网络空间中
## 容器的网络命名空间中: 添加网卡, 网卡是veth的另一端${GUEST_IFNAME} 
ip link  set "$GUEST_IFNAME" netns "$NSPID"
## 容器内的网卡: 重命名为eth1
ip netns exec "$NSPID" ip link set "$GUEST_IFNAME" name eth1 
## 容器内的网卡: 设置网卡地址
ip netns exec "$NSPID" ip addr add "$CONTAINER_CIDR_IPADDR" dev eth1 
## 容器内的网卡: 启动网卡
ip netns exec "$NSPID" ip link set eth1 up


# Give our ARP neighbors a nudge about the new interface
IPADDRONLY=$(echo "$CONTAINER_CIDR_IPADDR" | cut -d/ -f1)
ip netns exec "$NSPID" arping -c 1 -A -I eth1 "$CONTAINER_CIDR_IPADDR" > /dev/null 2>&1 || true

rm -f "/var/run/netns/$NSPID"



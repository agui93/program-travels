#!/bin/bash
###########################################################
##
## 数据链路层(二层网络): aix solaris gemini gateway netb sun svr4 bsdi slip
##
## veth设备的特点: 一端网卡发送的报文，另外一端网卡会收到该报文
## 具体的接入情况:
##     独立的bridge: aix solaris gemini gateway netb 
##     独立的bridge: sun svr4 bsdi
##     veth: slip(slipside)     和  bsdi(bsdiside)
##     veth: sun(sunside)       和  netb(netbside)
##     veth: gateway(gatewayin) 和  主机(gatewayout) 
## 
###########################################################

# 基于openvswitch创建两个网桥(叫做bridge或switch): net1 net2, 代表两个二层网络;
# 二层网络指的就是数据链路层，三层网络指的就是网络层
echo "create bridges by openvswitch: net1 net2"
ovs-vsctl add-br net1
ovs-vsctl add-br net2
ip link set net1 up

CONTAINERS=(aix solaris gemini gateway netb sun svr4 bsdi slip)

declare -A CONTAINER_2_NSPID
for CON_NAME in ${CONTAINERS[*]};
do
	NSPID=$(docker inspect --format='{{ .State.Pid }}' "$CON_NAME")
	CONTAINER_2_NSPID[${CON_NAME}]=${NSPID}
	rm -f "/var/run/netns/$NSPID"
	ln -s "/proc/$NSPID/ns/net" "/var/run/netns/$NSPID"
done

declare -A CONTAINER_2_BRIDGE
CONTAINER_2_BRIDGE[aix]=net1
CONTAINER_2_BRIDGE[solaris]=net1
CONTAINER_2_BRIDGE[gemini]=net1
CONTAINER_2_BRIDGE[gateway]=net1
CONTAINER_2_BRIDGE[netb]=net1
CONTAINER_2_BRIDGE[bsdi]=net2
CONTAINER_2_BRIDGE[sun]=net2
CONTAINER_2_BRIDGE[svr4]=net2


# 连接容器和交换机: 把容器网卡接入到交换机Port
for CONTAINER_NAME in ${!CONTAINER_2_BRIDGE[@]};
do
	BRIDGE_IFNAME=${CONTAINER_2_BRIDGE[${CONTAINER_NAME}]}
	NSPID=${CONTAINER_2_NSPID[${CONTAINER_NAME}]}
	MTU=$(ip link show "$BRIDGE_IFNAME" | awk '{print $5}')
	LOCAL_IFNAME="veth1pl${NSPID}"
	GUEST_IFNAME="veth1pg${NSPID}"
	echo ${CONTAINER_NAME} ${BRIDGE_IFNAME} ${LOCAL_IFNAME} ${GUEST_IFNAME}	

	ip link add name "$LOCAL_IFNAME" mtu "$MTU" type veth peer name "$GUEST_IFNAME" mtu "$MTU"
	
	# vswitch中添加port: 把veth的${LOCAL_IFNAME}端接入bridge, 并启动网卡
	ovs-vsctl add-port "$BRIDGE_IFNAME" "$LOCAL_IFNAME"
	ip link set "$LOCAL_IFNAME" up

	# 把${GUEST_IFNAME}安装在容器的网络空间中, 网卡重命名为eht1, 并启动网卡
	ip link  set "$GUEST_IFNAME" netns "$NSPID"
	ip netns exec "$NSPID" ip link set "$GUEST_IFNAME" name eth1 
	ip netns exec "$NSPID" ip link set eth1 up
done


# 连接: slip 和 bsdi
ip link add name slipside  mtu 1500 type veth peer name bsdiside   mtu 1500
ip link set slipside netns ${CONTAINER_2_NSPID[slip]}
ip link set bsdiside netns ${CONTAINER_2_NSPID[bsdi]}
ip netns exec ${CONTAINER_2_NSPID[slip]} ip link set slipside up
ip netns exec ${CONTAINER_2_NSPID[bsdi]} ip link set bsdiside up


# 连接: sun 和 netb
ip link add name sunside   mtu 1500 type veth peer name netbside   mtu 1500
ip link set sunside  netns ${CONTAINER_2_NSPID[sun]}
ip link set netbside netns ${CONTAINER_2_NSPID[netb]}
ip netns exec ${CONTAINER_2_NSPID[sun]}  ip link set sunside  up
ip netns exec ${CONTAINER_2_NSPID[netb]} ip link set netbside up


# 连接: gateway 和 主机
ip link add name gatewayin mtu 1500 type veth peer name gatewayout mtu 1500
ip link set gatewayin netns ${CONTAINER_2_NSPID[gateway]}
ip netns exec ${CONTAINER_2_NSPID[gateway]}  ip link set gatewayin up
ip link set gatewayout up





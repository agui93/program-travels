#!/bin/bash
###########################################################
##
##
##
###########################################################


# 基于openvswitch创建两个网桥(叫做bridge或switch): net1 net2, 代表两个二层网络;
# 二层网络指的就是数据链路层，三层网络指的就是网络层
echo "create bridges by openvswitch: net1 net2"
ovs-vsctl add-br net1
ovs-vsctl add-br net2
ip link set net1 up

echo "container slip don't need connect to net1 and net2"

echo "connect containers to net1 bridge: aix solaris gemini gateway netb"
./func_join_container_2_bridge.sh net1 aix     140.252.1.92/24
./func_join_container_2_bridge.sh net1 solaris 140.252.1.32/24
./func_join_container_2_bridge.sh net1 gemini  140.252.1.11/24
./func_join_container_2_bridge.sh net1 gateway 140.252.1.4/24
./func_join_container_2_bridge.sh net1 netb    140.252.1.183/24

echo "connect containers to net2 bridge: bsdi sun svr4"
./func_join_container_2_bridge.sh net2 bsdi 140.252.13.35/27
./func_join_container_2_bridge.sh net2 sun  140.252.13.33/27
./func_join_container_2_bridge.sh net2 svr4 140.252.13.34/27




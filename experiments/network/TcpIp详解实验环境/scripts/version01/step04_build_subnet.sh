#!/bin/bash
#########################################################
## 
## 子网划分:
##   140.252.1.0/24   :  140.252.1.0/24    
##   140.252.13.32/27 :  140.252.13.[001,00000]/27
##   140.252.13.64/27 :  140.252.13.[010,00000]/27
##   140.252.104.0/24 :  140.252.104.0/24
##   
## ip地址:
##   140.252.1.0/24子网
##     gateway 140.252.1.4/24    140.252.104.2/24 
##     aix     140.252.1.92/24
##     solaris 140.252.1.32/24
##     gemini  140.252.1.11/24  
##     netb    140.252.1.183/24 
##   
##   140.252.13.32/27子网
##     sun     140.252.13.33/27  140.252.1.29/24
##     svr4    140.252.13.34/27
##     bsdi    140.252.13.35/27  140.252.13.66/27
##
##   140.252.13.64/27子网:
##     slip   140.252.13.65/27
##
## veth设备的特点: 一端网卡发送的报文，另外一端网卡会收到该报文
## 数据链路层(二层网络):
##   net1: gateway aix solaris gemini netb
##   net2: sun svr4 bsdi
##   veth: bsdi and slip 
##   veth: sun  and netb
##   veth: gateway and HOST 
##
##
## 网络间的关系:
##   140.252.13.64/27子网: 关联 140.252.13.32/27子网
##   140.252.13.32/27子网: 关联 140.252.13.64/27子网 和 140.252.1.0/24子网
##   140.252.1.0/24子网  : 关联 140.252.13.32/27子网 和 140.252.104.0/24子网
##   140.252.104.0/24子网: 关联 140.252.1.0/24子网   和 主机网络(即外网)
## 
## 路由策略: 每个子网保证既能访问所关联网络，又能访问外网
##  
## 几个典型的样例分析: ip层的路由策略
##   slip访问svr4 
##   svr4访问aix
##   aix访问外网 
##   slip访问aix
##   slip访问外网 
##   主机访问slip
## 
#########################################################


publiceth=$1
imagename=$2

# 添加从slip到bsdi的p2p网络
echo "add p2p from slip to bsdi"

# 创建一个peer的两个网卡: slipside网卡 和 bsdiside网卡
ip link add name slipside mtu 1500 type veth peer name bsdiside mtu 1500
# slip: 把slipside网卡加入到slip容器的网络namespace中，网卡添加IP地址是140.252.13.65/27
SLIP_DOCKERPID=$(docker inspect '--format={{ .State.Pid }}' slip)
ln -s /proc/${SLIP_DOCKERPID}/ns/net /var/run/netns/${SLIP_DOCKERPID}
ip link set slipside netns ${SLIP_DOCKERPID}
docker exec -it slip ip addr add 140.252.13.65/27 dev slipside
docker exec -it slip ip link set slipside up
# bsdi: 把bsdiside网卡加入到bsdi容器的网络namespace中，网卡添加IP地址是140.252.13.66/27
BSDI_DOCKERPID=$(docker inspect '--format={{ .State.Pid }}' bsdi)
ln -s /proc/${BSDI_DOCKERPID}/ns/net /var/run/netns/${BSDI_DOCKERPID}
ip link set bsdiside netns ${BSDI_DOCKERPID}
docker exec -it bsdi ip addr add 140.252.13.66/27 dev bsdiside
docker exec -it bsdi ip link set bsdiside up


# 140.252.13.64/27子网是: 140.252.13.[010,00000]/27
# 140.252.13.32/27子网是: 140.252.13.[001,00000]/27
# 140.252.13.64/27 和 140.252.13.32/27是不同的网络, 二者之间需要配置合理的路由策略
# slip: 位于140.252.13.64/27子网
# bsdi: 位于140.252.13.32/27子网 并且 位于140.252.13.64/27子网
# svr4: 位于140.252.13.32/27子网
# sun : 位于140.252.13.32/27子网 并且 位于140.252.1.0/24子网
# 所以: slip对外访问时, 默认网关是140.252.13.66
# 所以: bsdi svr4对外访问时, 默认网关是140.252.13.33
# 所以: sun svr4访问140.252.13.64/27子网时, 网关是140.252.13.35

# slip: 对外访问的默认网关是140.252.13.66
docker exec -it slip ip route add default via 140.252.13.66 dev slipside

# bsdi svr4: 对外访问的默认网关是140.252.13.33
docker exec -it bsdi ip route add default via 140.252.13.33 dev eth1
docker exec -it svr4 ip route add default via 140.252.13.33 dev eth1

# sun svr4: 访问140.252.13.64/27子网, 网关是140.252.13.35
docker exec -it sun  ip route add 140.252.13.64/27 via 140.252.13.35 dev eth1
docker exec -it svr4 ip route add 140.252.13.64/27 via 140.252.13.35 dev eth1




# 添加从sun到netb的点对点网络
echo "add p2p from sun to netb"

# 创建一个peer的网卡对: sunside 和 netbside
ip link add name sunside mtu 1500 type veth peer name netbside mtu 1500
# sun: 把sunside网卡加入到sun容器的网络namespace中, sunside网卡地址被设置为140.252.1.29/24, 启动sunside网卡
DOCKERPID3=$(docker inspect '--format={{ .State.Pid }}' sun)
ln -s /proc/${DOCKERPID3}/ns/net /var/run/netns/${DOCKERPID3}
ip link set sunside netns ${DOCKERPID3}
docker exec -it sun ip addr add 140.252.1.29/24 dev sunside
docker exec -it sun ip link set sunside up
# netb: 把netbside网卡加入到sunb容器的网络namespace中, netbside网卡未设置ip地址, 启动netbside网卡
DOCKERPID4=$(docker inspect '--format={{ .State.Pid }}' netb)
ln -s /proc/${DOCKERPID4}/ns/net /var/run/netns/${DOCKERPID4}
ip link set netbside netns ${DOCKERPID4}
docker exec -it netb ip link set netbside up


# sun netb: 对外访问的默认路由是1.4
docker exec -it sun  ip route add default via 140.252.1.4 dev sunside
docker exec -it netb ip route add default via 140.252.1.4 dev eth1

# netb: netbside网卡未设置ip地址, 但是需要配置路由规则，访问到下面的二层网络
docker exec -it netb ip route add 140.252.1.29/32  dev netbside
docker exec -it netb ip route add 140.252.13.32/27 via 140.252.1.29 dev netbside
docker exec -it netb ip route add 140.252.13.64/27 via 140.252.1.29 dev netbside


# netb: 不是一个普通的路由器，因为netb两边是同一个二层网络，所以需要配置arp proxy，将同一个二层网络隔离称为两个。
echo "config arp proxy for netb"
docker exec -it netb bash -c "echo 1 > /proc/sys/net/ipv4/conf/eth1/proxy_arp"
docker exec -it netb bash -c "echo 1 > /proc/sys/net/ipv4/conf/netbside/proxy_arp"
docker exec -it netb bash -c "arp -s 140.252.1.29 -i eth1     -D eth1     pub"
docker exec -it netb bash -c "arp -s 140.252.1.92 -i netbside -D netbside pub"
docker exec -it netb bash -c "arp -s 140.252.1.32 -i netbside -D netbside pub"
docker exec -it netb bash -c "arp -s 140.252.1.11 -i netbside -D netbside pub"
docker exec -it netb bash -c "arp -s 140.252.1.4  -i netbside -D netbside pub"



# 配置上面的二层网络里面所有机器的路由
echo "config all routes"


# aix solaris gemini: 默认外网访问路由是140.252.1.4
docker exec -it aix     ip route add default via 140.252.1.4 dev eth1
docker exec -it solaris ip route add default via 140.252.1.4 dev eth1
docker exec -it gemini  ip route add default via 140.252.1.4 dev eth1


# aix solaris gemini gateway: 路由到140.252.13.32/27的网关是140.252.1.29 
docker exec -it aix     ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it solaris ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it gemini  ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it gateway ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1


# aix solaris gemini gateway: 路由到140.252.13.64/27的网关是140.252.1.29 
docker exec -it aix     ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1
docker exec -it solaris ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1
docker exec -it gemini  ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1
docker exec -it gateway ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1




# 配置外网访问
echo "add public network"
# 创建一个peer的网卡对: gatewayin 和 gatewayout
ip link add name gatewayin mtu 1500 type veth peer name gatewayout mtu 1500

# gateway: gatewayin网卡放入gateway容器的网络namespace里, gatewayin网卡地址设置为140.252.104.2/24, 启动gatewayin网卡
DOCKERPID5=$(docker inspect '--format={{ .State.Pid }}' gateway)
ln -s /proc/${DOCKERPID5}/ns/net /var/run/netns/${DOCKERPID5}
ip link set gatewayin netns ${DOCKERPID5}
docker exec -it gateway ip addr add 140.252.104.2/24 dev gatewayin
docker exec -it gateway ip link set gatewayin up

# 主机: gatewayout网卡默认在主机的网络namespace中, gatewayout网卡地址设置为140.252.104.1/24, 启动gatewayout网卡
ip addr add 140.252.104.1/24 dev gatewayout
ip link set gatewayout up


# gateway: 对外访问的默认路由是140.252.104.1/24
docker exec -it gateway ip route add default via 140.252.104.1 dev gatewayin


# 主机: 使用MASQUERADE进行动态的SNAT操作, IP报文的源IP修改为${publiceth}网卡中可用的地址
iptables -t nat -A POSTROUTING -o ${publiceth} -j MASQUERADE

# 主机: 主机访问140子网时的路由  
ip route add 140.252.13.32/27 via 140.252.104.2 dev gatewayout
ip route add 140.252.13.64/27 via 140.252.104.2 dev gatewayout
ip route add 140.252.1.0/24   via 140.252.104.2 dev gatewayout





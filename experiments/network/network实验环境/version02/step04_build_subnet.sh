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
## 140.252.13.64/27子网是: 140.252.13.[010,00000]/27
## 140.252.13.32/27子网是: 140.252.13.[001,00000]/27
## 140.252.13.64/27 和 140.252.13.32/27是不同的网络, 二者之间需要配置合理的路由策略
## slip: 位于140.252.13.64/27子网
## bsdi: 位于140.252.13.32/27子网 并且 位于140.252.13.64/27子网
## svr4: 位于140.252.13.32/27子网
## sun : 位于140.252.13.32/27子网 并且 位于140.252.1.0/24子网
## 所以: slip对外访问时, 默认网关是140.252.13.66
## 所以: bsdi svr4对外访问时, 默认网关是140.252.13.33
## 所以: sun svr4访问140.252.13.64/27子网时, 网关是140.252.13.35
## 
#########################################################

publiceth=$1


# bsdi sun netb上多块网卡的地址
docker exec -it slip    ip addr add 140.252.13.65/27 dev slipside
docker exec -it bsdi    ip addr add 140.252.13.66/27 dev bsdiside  #和slip的slipside是一组veth设备

docker exec -it bsdi    ip addr add 140.252.13.35/27 dev eth1
docker exec -it svr4    ip addr add 140.252.13.34/27 dev eth1
docker exec -it sun     ip addr add 140.252.13.33/27 dev eth1

docker exec -it sun     ip addr add 140.252.1.29/24  dev sunside   #和netb的netbsize是一组设备
docker exec -it netb    ip addr add 140.252.1.183/24 dev eth1
docker exec -it aix     ip addr add 140.252.1.92/24  dev eth1
docker exec -it solaris ip addr add 140.252.1.32/24  dev eth1
docker exec -it gemini  ip addr add 140.252.1.11/24  dev eth1
docker exec -it gateway ip addr add 140.252.1.4/24   dev eth1

docker exec -it gateway ip addr add 140.252.104.2/24 dev gatewayin
ip addr add 140.252.104.1/24 dev gatewayout


echo "route: slip => bsdi sun svr4"
echo "  ==>: slip(slipside)地址: 140.252.13.65/27"
echo "  ==>: bsdi(bsdiside)地址: 140.252.13.66/27"
echo "  ==>: veth: (bsdi:bsdiside) and (slip:slipside)"
echo "  ==>: slip(slipside)默认网关: 140.252.13.66, 该网关位于bsdi:bsdiside"
echo "  ==>: bsdi sun svr4: 同时位于140.252.13.32/27"
echo ""
docker exec -it slip ip route add default via 140.252.13.66 dev slipside

echo "route: bsdi => slip"
echo "  ==>: slip(slipside)地址: 140.252.13.65/27"
echo "  ==>: bsdi(bsdiside)地址: 140.252.13.66/27"
echo "  ==>: veth: (bsdi:bsdiside) and (slip:slipside)"
echo ""


echo "route: sun svr4 => slip, 即(140.252.13.32/27)=>(140.252.13.64/27)"
echo "  ==>: bsdi(eth1): 140.252.13.35/27"
echo "  ==>: bsdi sun svr4: 同时位于140.252.13.32/27"
echo "  ==>: bsdi => slip: 140.252.13.64/27"
echo "  ==>: so, sun svr4: 通过网关140.252.13.35, 访问140.252.13.64/27"
echo ""
docker exec -it sun  ip route add 140.252.13.64/27 via 140.252.13.35 dev eth1
docker exec -it svr4 ip route add 140.252.13.64/27 via 140.252.13.35 dev eth1




echo "route: sun => netb"
echo "  => veth: sun(sunside) and netb(netbside)"
echo "  => net(netbside): address none"
echo "  => sun(sunside): 地址140.252.1.29/24, 位于网络140.252.1.0/24"
echo ""

echo "route: netb => sun"
echo "   ==> 即: netb => sun => 140.252.13.32/27"
echo ""
docker exec -it netb ip route add 140.252.1.29/32  dev netbside



echo "route: bsdi,svr4 => *"
echo "  ==> sun(eth1): 140.252.13.33/27" 
echo "  ==> sun bsdi svr4: 位于同样的140.252.13.32/27"
echo "  ==> route: sun <=> netb"
echo "  ==> route: netb <=> gateway"
echo "  ==> route: gateway <=> 主机 <=> public network"
echo "  ==> so, bsdi svr4i: 默认网关是140.252.13.33"
echo ""
docker exec -it bsdi ip route add default via 140.252.13.33 dev eth1
docker exec -it svr4 ip route add default via 140.252.13.33 dev eth1



echo "route: sun => *"
echo "  ==> sun: 默认网关是140.252.1.4"
echo ""
docker exec -it sun  ip route add default via 140.252.1.4 dev sunside

echo "route: netb => *"
echo "  ==> netb: 默认网关是140.252.1.4"
echo ""
docker exec -it netb ip route add default via 140.252.1.4 dev eth1

echo "route: netb => 140.252.13.32/27"
echo "route: netb => 140.252.13.64/27"
docker exec -it netb ip route add 140.252.13.32/27 via 140.252.1.29 dev netbside
docker exec -it netb ip route add 140.252.13.64/27 via 140.252.1.29 dev netbside


echo "arp proxy for netb"
echo "  ==> netb: 不是一个普通的路由器"
echo "  ==> netb: 两边是同一个二层网络，所以需要配置arp proxy，将同一个二层网络隔离称为两个"
echo ""
docker exec -it netb bash -c "echo 1 > /proc/sys/net/ipv4/conf/eth1/proxy_arp"
docker exec -it netb bash -c "echo 1 > /proc/sys/net/ipv4/conf/netbside/proxy_arp"
docker exec -it netb bash -c "arp -s 140.252.1.29 -i eth1     -D eth1     pub"
docker exec -it netb bash -c "arp -s 140.252.1.92 -i netbside -D netbside pub"
docker exec -it netb bash -c "arp -s 140.252.1.32 -i netbside -D netbside pub"
docker exec -it netb bash -c "arp -s 140.252.1.11 -i netbside -D netbside pub"
docker exec -it netb bash -c "arp -s 140.252.1.4  -i netbside -D netbside pub"



echo "route: aix solaris gemini gateway => 140.252.13.32/27"
echo "  ==> sun(sunside): 140.252.1.29"
echo "  ==> sun(eth1): 140.252.13.33/27, 位于140.252.13.32/27"
echo "  ==> aix solaris gemini gateway: 通过140.252.1.29网关, 路由到140.252.13.32/27网络"
echo ""
docker exec -it aix     ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it solaris ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it gemini  ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1
docker exec -it gateway ip route add 140.252.13.32/27 via 140.252.1.29 dev eth1


echo "route: aix solaris gemini gateway => 140.252.13.64/27"
echo "  ==> sun(sunside): 140.252.1.29"
echo "  ==> aix solaris gemini gateway => netb => 140.252.1.29"
echo "  ==> sun route: => 140.252.13.64/27"
echo "  ==> aix solaris gemini gateway: 通过140.252.1.29网关, 路由到140.252.13.64/27网络"
echo ""
docker exec -it aix     ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1
docker exec -it solaris ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1
docker exec -it gemini  ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1
docker exec -it gateway ip route add 140.252.13.64/27 via 140.252.1.29 dev eth1




echo "route: gateway => 主机"
echo "  ==> gateway容器: 默认网关140.252.104.1 BY gatewayin网卡"
echo "  ==> gatewayin : 140.252.104.2/24, 位于gateway容器内"
echo "  ==> gatewayout: 140.252.104.1/24, 位于主机内"
echo "  ==> veth: gatewayout and gatewayin"
echo ""
docker exec -it gateway ip route add default via 140.252.104.1 dev gatewayin

echo "iptables: gateway => 主机 <<=(SNAT)=>> public network"
echo "  ==> 主机使用MASQUERADE进行动态的SNAT操作"
echo "  ==> IP报文的源IP修改为${publiceth}网卡中可用的地址"
echo "  ==> 容器内的网络地址是主机内部私有的,访问public network需要SNAT"
iptables -t nat -A POSTROUTING -o ${publiceth} -j MASQUERADE


echo "route: 主机 => 140.252.1.0/24, 140.252.13.32/27, 140.252.13.64/27"
echo "  ==> 匹配140.252.1.0/24  的数据报, 通过gatewayout网卡, 发给网关140.252.104.2"
echo "  ==> 匹配140.252.13.32/27的数据报, 通过gatewayout网卡, 发给网关140.252.104.2"
echo "  ==> 匹配140.252.13.64/27的数据报, 通过gatewayout网卡, 发给网关140.252.104.2"
echo "  ==> gatewayout: 140.252.104.1/24, 位于主机内"
echo "  ==> gatewayin : 140.252.104.2/24, 位于gateway容器内"
echo "  ==> veth: gatewayout and gatewayin"
echo "  ==> gateway容器: route => 140.252.1.0/24, 140.252.13.32/27, 140.252.13.64/27 "
echo ""
ip route add 140.252.1.0/24   via 140.252.104.2 dev gatewayout
ip route add 140.252.13.32/27 via 140.252.104.2 dev gatewayout
ip route add 140.252.13.64/27 via 140.252.104.2 dev gatewayout


echo "route: gateway <=> aix solaris gemini"
echo "  ==> gateway(eth1): 140.252.1.4/24"
echo "  ==> aix solaris gemini gateway: 位于140.252.1.0/24网络"
echo ""


echo "route: aix solaris gemini => public network"
echo "  ==> gateway(eth1): 140.252.1.4/24"
echo "  ==> gateway => public network"
echo "  ==> so, aix solaris gemini 默认网关是: 140.252.1.4"
echo ""
docker exec -it aix     ip route add default via 140.252.1.4 dev eth1
docker exec -it solaris ip route add default via 140.252.1.4 dev eth1
docker exec -it gemini  ip route add default via 140.252.1.4 dev eth1






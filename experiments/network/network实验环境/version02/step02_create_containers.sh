#!/bin/bash
##################################################
##
## 创建容器: aix solaris gemini gateway netb sun svr4 bsdi slip
## 基于镜像: tcpip/ubuntu:experiment 
##
##################################################

imagename='tcpip/ubuntu:experiment'
CONTAINERS=(aix solaris gemini gateway netb sun svr4 bsdi slip)

# 使用docker创建容器, 容器暂时不设置网络
echo "create all containers: aix solaris gemini gateway netb sun svr4 bsdi slip"
for CNAME in ${CONTAINERS[*]};
do
    docker run --privileged=true --net none --hostname ${CNAME} --name ${CNAME} -d ${imagename}
done





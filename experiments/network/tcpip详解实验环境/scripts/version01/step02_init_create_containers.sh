#!/bin/bash

publiceth=$1  # 网卡
imagename=$2  # 镜像

# 使用docker创建容器, 容器暂时不设置网络
echo "create all containers: aix solaris gemini gateway netb sun svr4 bsdi slip"

CONTAINERS=(aix solaris gemini gateway netb sun svr4 bsdi slip)
for CNAME in ${CONTAINERS[*]};
do
    docker run --privileged=true --net none --hostname ${CNAME} --name ${CNAME} -d ${imagename}
done


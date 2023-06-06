#!/bin/bash
# 重新安装前的清理

docker stop aix solaris gemini gateway netb sun svr4 bsdi slip
docker rm aix solaris gemini gateway netb sun svr4 bsdi slip

ovs-vsctl del-br net1 
ovs-vsctl del-br net2

echo $(ip netns list |grep -v id)
for nsid in $(ip netns list |grep -v id); do ip netns delete ${nsid}; done
echo $(ip netns list |grep -v id)




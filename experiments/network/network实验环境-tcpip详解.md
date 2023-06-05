
# 搭建VM
```bash
# 版本jammy, ubuntu是22.04
multipass launch --mem 8G --disk 24G --cpus 2 --network en0 --network name=bridge0,mode=manual --name vm-network

multipass shell vm-network
sudo -s
apt update
```



# 安装docker

```bash
apt install docker.io -y
systemctl status docker
systemctl enable docker
journalctl -xeu docker 
journalctl -f -u docker
journalctl -xeu containerd 
journalctl -f -u containerd


# 定制docker配置
tee /etc/docker/daemon.json <<EOF
{
      "exec-opts": ["native.cgroupdriver=cgroupfs"],
      "log-driver": "json-file",
      "log-opts": {
          "max-size": "100m"
       },
       "storage-driver": "overlay2",
       "registry-mirrors": [
            "https://b9pmyelo.mirror.aliyuncs.com",
            "https://registry.docker-cn.com",
            "http://hub-mirror.c.163.com",
            "https://docker.mirrors.ustc.edu.cn"
        ]
}
EOF
systemctl daemon-reload
systemctl restart docker
systemctl status docker

# 实验docker container
docker pull ubuntu:22.04
docker run --privileged=true -i -t -d --name hello ubuntu:22.04
docker exec -it hello /bin/bash
apt-get -y update && apt-get install -y iproute2 iputils-arping net-tools tcpdump curl telnet iputils-tracepath traceroute
apt-get -y install vim openssh-server
```


## 安装docker(另外一种安装方式)
```bash
# 教程: https://linux.cn/article-14871-1.html

apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null


apt update
# apt-cache madison docker-ce
# dpkg --configure -a
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl status docker
journalctl -xeu docker 
journalctl -f -u docker
journalctl -xeu containerd 
journalctl -f -u containerd


# docker基本信息
docker info
docker inspect bridge
brctl show

# 实验docker container
docker pull ubuntu:22.04
docker run --privileged=true -i -t -d --name hello ubuntu:22.04
docker exec -it hello /bin/bash
apt-get -y update && apt-get install -y iproute2 iputils-arping net-tools tcpdump curl telnet iputils-tracepath traceroute
apt-get -y install vim openssh-server
```


# 安装工具
```bash
apt-get -y install openvswitch-common openvswitch-dbg openvswitch-switch openvswitch-ipsec openvswitch-pki openvswitch-vtep

apt-get -y install bridge-utils
apt-get -y install arping
apt-get -y install net-tools 

# 开机自启动
service openvswitch-switch status
cd /usr/share/openvswitch/scripts
./ovs-ctl status

# 帮助命令
ovs-vsctl show
ovs-vsctl list-br
ovs-vsctl del-br net1
ovs-vsctl del-br net2
ovs-vsctl add-br net1
ovs-vsctl add-br net2
```



# 构建镜像



构建基础镜像
```bash
# 目录
mkdir -p /root/images/tcpip && cd /root/images/tcpip

# dockerfile文件
cat <<EOF > Dockerfile
FROM ubuntu:22.04
RUN apt-get -y update && apt-get install -y iproute2 iputils-arping net-tools tcpdump curl telnet iputils-tracepath traceroute

RUN apt-get -y install openbsd-inetd 
RUN echo "\
discard     stream  tcp nowait  root    internal \n\
discard     dgram   udp wait    root    internal \n\
daytime     stream  tcp nowait  root    internal \n\
time        stream  tcp nowait  root    internal \n\
echo        stream  tcp nowait  root    internal \n\
" >> /etc/inetd.conf 

RUN apt-get -y install vim openssh-server iputils-ping
RUN mkdir /run/sshd

RUN echo "\
/etc/init.d/openbsd-inetd start \n\
/usr/sbin/sshd -D \n\
" > /start.sh
RUN chmod u+x /start.sh 

CMD ["/bin/bash", "-c", "/start.sh"]
EOF

# 构建镜像
docker build -t tcpip/ubuntu:experiment . 

# 启动continaer, 并验证
docker run --privileged=true -i -t -d --name test tcpip/ubuntu:experiment
docker exec -it test ss -nlp
docker exec -it test ps aux
docker rm -f test
```


# 安装网络实验环境


```bash
# 安装前，查看网络情况
ip a 
ip route
ip link
ip link show type veth
ip --all netns exec ip link show type veth
ls -al /var/run/netns/
ip -all netns exec ip a
ls -al /sys/class/net/*/iflink
ovs-vsctl show 
ovs-vsctl list-br
brctl show
docker inspect bridge


# 根据version01版本构建网络实验环境
# 或者根据version02版本构建网络实验环境

# 安装后，查看网络情况
ip link
ip a 
ip route
ip link show type veth
ip --all netns exec ip link show type veth
ls -al /var/run/netns/
ip -all netns exec ip a
ls -al /sys/class/net/*/iflink
ovs-vsctl show 
ovs-vsctl list-br
brctl show
docker inspect bridge


# 重新安装实验环境的清理工作
docker stop aix solaris gemini gateway netb sun svr4 bsdi slip
docker rm aix solaris gemini gateway netb sun svr4 bsdi slip
ovs-vsctl del-br net1 
ovs-vsctl del-br net2
echo $(ip netns list |grep -v id)
for nsid in $(ip netns list |grep -v id); do ip netns delete ${nsid}; done
echo $(ip netns list |grep -v id)
```







# 如何划分VLAN
```bash
# 加载内核模块8021q
lsmod | grep -i 8021q
modprobe --first-time 8021q
lsmod | grep -i 8021q

# 列出8021q的信息
modinfo 8021q

# 使用ip命令创建vlan 100和vlan 200到enp0s8网卡
ip link add link enp0s8 name enp0s8.100 type vlan id 100
ip link add link enp0s8 name enp0s8.200 type vlan id 200
ip link show type vlan


# 使用enp0s8.100 enp0s8.200网卡ping 
ping -c3 baidu.com -i enp0s8.100
ping -c3 baidu.com -i enp0s8.200


# 删除vlan网卡
ip link del dev enp0s8.100
ip link del dev enp0s8.200
ip link show type vlan
```




# VLAN实验

- 后续补充
	- 文字描述了实验结果，实验时未截图
	- 实验设计图


```bash
# 加载内核模块8021q
lsmod | grep -i 8021q
modprobe --first-time 8021q
lsmod | grep -i 8021q

# 列出8021q的信息
modinfo 8021q

# 使用ip命令创建vlan 100和vlan 200到enp0s8网卡
ip link add link enp0s8 name enp0s8.100 type vlan id 100
ip link add link enp0s8 name enp0s8.200 type vlan id 200
ip link show type vlan

# 验证enp0s8.100 enp0s8.200有效
ping -c1 baidu.com -i enp0s8.100
ping -c1 baidu.com -i enp0s8.200


# 创建bridge设备: br100 br200
brctl addbr br100
brctl addbr br200
ip link set br100 up
ip link set br200 up
ip link show type bridge
brctl show

# bridge设备: 添加vlan网卡
brctl addif br100 enp0s8.100
brctl addif br200 enp0s8.200
brctl show


# 添加netns: nsa nsb
ip netns add nsa
ip netns exec nsa ip link set lo up
ip netns add nsb
ip netns exec nsb ip link set lo up


# 添加veth: veth-a(接入nsa) veth-br-a(接入br100)
ip link add name veth-a mtu 1500 type veth peer name veth-br-a mtu 1500
ip link set dev veth-a netns nsa
ip netns exec nsa ip link set veth-a up
ip netns exec nsa ip a
ip link set veth-br-a up
brctl addif br100 veth-br-a
brctl show br100


# 添加veth: veth-b(接入nsb) veth-br-a(接入br200)
ip link add name veth-b mtu 1500 type veth peer name veth-br-b mtu 1500
ip link set dev veth-b netns nsb
ip netns exec nsb ip link set veth-b up
ip netns exec nsb ip a
ip link set veth-br-b up
brctl addif br200 veth-br-b
brctl show br200



# 在nsa中设置网卡地址: 172.169.100.1/24
ip netns exec nsa ip addr add 172.169.100.1/24 dev veth-a
ip netns exec nsa ip a
ip netns exec nsa ip route
ip netns exec nsa route -n
ip netns exec nsa ping -c1 172.169.100.1


# 在nsb中设置网卡地址: 172.169.200.2/24
ip netns exec nsb ip addr add 172.169.200.2/24 dev veth-b
ip netns exec nsb ip a
ip netns exec nsb ip route
ip netns exec nsb route -n
ip netns exec nsb ping -c1 172.169.200.2



# 172.169.100.1/24 和 172.169.200.2/24 ping不能互通: 三层网络不通
ip netns exec nsa ping -c1 172.169.200.2
ip netns exec nsb ping -c1 172.169.100.1



# 观测: 172.169.100.1 <=/=> 172.169.200.2, arping不通: 二层网络不通
# 172.169.100.1在vlan100, 172.169.200.2在vlan200
# enp0s8收到arp request进行广播时, 不会把arp vlan100 request发向vlan200(对应enp0s8.200网卡)
# 同理,enp0s8也不会把arp vlan200 request发给vlan100(对应enp0s8.100网卡)
ip netns exec nsa arping -c3 172.169.200.2
ip netns exec nsa tcpdump -i any -en
## 能观测到arp 172.169.200.2 request: veth-br-a br100 enp0s8.100 enp0s8
tcpdump -i veth-br-a -en
tcpdump -i br100 -en
tcpdump -i enp0s8.100 -en
tcpdump -i enp0s8 vlan -en
## enp0s8.200: 不能观测到arp 172.169.200.2 request
tcpdump -i enp0s8.200 -en  



# 新创建在netns: nsaa, 使用veth关联nsaa和br100, nsaa中网卡地址: 172.169.100.11/24
ip netns add nsaa
ip link add name veth-aa mtu 1500 type veth peer name veth-br-aa mtu 1500
ip link set veth-aa netns nsaa
ip netns exec nsaa ip link set lo up
ip netns exec nsaa ip link set veth-aa up
ip netns exec nsaa ip addr add 172.169.100.11/24 dev veth-aa
ip link set veth-br-aa up
brctl addif br100 veth-br-aa
ip netns exec nsaa ip a
brctl show br100


# 观测: 172.169.100.1 <=> 172.169.100.11, arping和ping操作通过
# 172.169.100.1 和 172.169.100.11 都在vlan100区域
ip netns exec nsa arping -c3 172.169.100.11
ip netns exec nsa ping -c3 172.169.100.11
## 观测命令
### veth-br-a br100 veth-br-aa: 能观测到arp  172.169.100.11 request, 也能观测到reply
tcpdump -i veth-br-a -en
tcpdump -i br100 -en
tcpdump -i veth-br-aa -en
### veth-aa: 能观测到arp  172.169.100.11 request, 也能观测到reply
ip netns exec nsaa tcpdump -i veth-aa -en
### enp0s8.100: 能观测到arp  172.169.100.11 request, 观测不到reply
tcpdump -i enp0s8.100 -en
### enp0s8: 能观测到arp  172.169.100.11 request, 观测不到reply
tcpdump -i enp0s8 vlan -en
### enp0s8.200: 观测不到arp  172.169.100.11 request
tcpdump -i enp0s8.200 -en


# nsaa中的网卡添加: 172.169.101.11/24
ip netns exec nsaa ip addr add 172.169.101.11/24 dev veth-aa
## arping能通: 同在一个vlan100区域, 二层网络互通, 所有arping能通
ip netns exec nsa arping -c3 172.169.101.11
## ping不通: 172.169.100.1/24 和 172.169.101.11/24 不是一个子网, 没有设置特定的路由, 所以三层网络不通
ip netns exec nsa ping -c3 172.169.101.11


# 问题: 172.169.100.1 和 172.169.200.2 如何互通呢? 
# 答案: 路由(使用虚拟路由模拟)

# 创建nsroute, 使用veth关联nsroute和br100, 使用veth关联nsroute和br200
ip netns add nsroute
ip link add name veth-route-br-a mtu 1500 type veth peer name veth-route-a mtu 1500
ip link set veth-route-a up
brctl addif br100 veth-route-a
brctl show br100
ip link set veth-route-br-a netns nsroute
ip netns exec nsroute ip link set lo up
ip netns exec nsroute ip link set veth-route-br-a up
ip netns exec nsroute ip a

ip link add name veth-route-br-b mtu 1500 type veth peer name veth-route-b mtu 1500
ip link set veth-route-b up
brctl addif br200 veth-route-b
brctl show br200
ip link set veth-route-br-b netns nsroute 
ip netns exec nsroute ip link set lo up
ip netns exec nsroute ip link set veth-route-br-b up
ip netns exec nsroute ip a



# 在nsroute配置网卡
ip netns exec nsroute ip addr add 172.169.100.111/24 dev veth-route-br-a
ip netns exec nsroute ip addr add 172.169.200.111/24 dev veth-route-br-b
ip netns exec nsroute ip addr
ip netns exec nsroute route -n

# 在nsroute中可以ping通172.169.100.1 172.169.100.11 172.169.200.2
ip netns exec nsroute ping -c1 172.169.100.1
ip netns exec nsroute ping -c1 172.169.100.11
ip netns exec nsroute ping -c1 172.169.200.2


# 在nsa中配置默认路由
ip netns exec nsa ip route add default via 172.169.100.111 dev veth-a
# 在nsb中配置默认路由
ip netns exec nsb ip route add default via 172.169.200.111 dev veth-b
# 现在nsa的ip能ping通nsb中的ip
ip netns exec nsa ping -c1 172.169.200.2
# 现在nsb的ip能ping通nsa中的ip
ip netns exec nsb ping -c1 172.169.100.1


# 现在nsaa中的ip和nsb中的ip不能ping通, 因为nsaa中无对应的路由
ip netns exec nsaa ping -c1 172.169.200.2
# 在nsaa中配置默认路由
ip netns exec nsaa ip route add default via 172.169.100.111 dev veth-aa
# 可以ping通
ip netns exec nsaa ping -c1 172.169.200.2


# 删除本次实验用的设备
ip netns del nsa 
ip netns del nsb
ip netns del nsaa
ip netns del nsroute
ip netns list
ip link set br100 down
brctl delbr br100
ip link set br200 down
brctl delbr br200
brctl show
ip link del enp0s8.100 
ip link del enp0s8.200 
ip link show type vlan
```



# 记述一次错误的实验设计

- Linux Bridge + VLAN + veth的实验
- 实验设计错误

```bash
# 创建ns: ns-vlan-br ns-vlan-a ns-vlan-b
ip netns add ns-vlan-br
ip netns add ns-vlan-a
ip netns add ns-vlan-b
ip netns list


# 在ns-vlan-br中添加br: vlan-br
ip netns exec ns-vlan-br brctl addbr vlan-br
ip netns exec ns-vlan-br ip link set vlan-br up
ip netns exec ns-vlan-br brctl show
ip netns exec ns-vlan-br ip link show type bridge
ip netns exec ns-vlan-br ip a




# 在ns-vlan-a和ns-vlan-br中关联veth
ip link add name veth-a mtu 1500 type veth peer name veth-br-a mtu 1500

ip link set dev veth-a netns ns-vlan-a
ip netns exec ns-vlan-a ip link set veth-a up
ip netns exec ns-vlan-a ip link show type veth
ip netns exec ns-vlan-a ip a

ip link set dev veth-br-a netns ns-vlan-br
ip netns exec ns-vlan-br ip link set veth-br-a up
ip netns exec ns-vlan-br ip link show type veth
ip netns exec ns-vlan-br ip a


# 在ns-vlan-b和ns-vlan-br中关联veth
ip link add name veth-b mtu 1500 type veth peer name veth-br-b mtu 1500

ip link set dev veth-b netns ns-vlan-b
ip netns exec ns-vlan-b ip link set veth-b up
ip netns exec ns-vlan-b ip link show type veth
ip netns exec ns-vlan-b ip a

ip link set dev veth-br-b netns ns-vlan-br
ip netns exec ns-vlan-br ip link set veth-br-b up
ip netns exec ns-vlan-br ip link show type veth
ip netns exec ns-vlan-br ip a



# 在ns-vlan-a中配置vlan
ip netns exec ns-vlan-a ip link add link veth-a name veth-a.100 type vlan id 100
ip netns exec ns-vlan-a ip link add link veth-a name veth-a.200 type vlan id 200
ip netns exec ns-vlan-a ip link set veth-a.100 up
ip netns exec ns-vlan-a ip link set veth-a.200 up
ip netns exec ns-vlan-a cat /proc/net/vlan/config
ip netns exec ns-vlan-a ip link show type vlan
ip netns exec ns-vlan-a ip a


# 在ns-vlan-b中配置vlan
ip netns exec ns-vlan-b ip link add link veth-b name veth-b.100 type vlan id 100
ip netns exec ns-vlan-b ip link add link veth-b name veth-b.200 type vlan id 200
ip netns exec ns-vlan-b ip link set veth-b.100 up
ip netns exec ns-vlan-b ip link set veth-b.200 up
ip netns exec ns-vlan-b cat /proc/net/vlan/config
ip netns exec ns-vlan-b ip link show type vlan
ip netns exec ns-vlan-b ip a


# 在ns-vlan-a中配置ip和路由
ip netns exec ns-vlan-a ip addr add 172.16.30.1/24 dev veth-a.100
ip netns exec ns-vlan-a ip addr add 172.16.30.2/24 dev veth-a.200
ip netns exec ns-vlan-a ip link show type vlan
ip netns exec ns-vlan-a ip a show type vlan
ip netns exec ns-vlan-a route add 172.16.30.21 dev veth-a.100
ip netns exec ns-vlan-a route add 172.16.30.22 dev veth-a.200
ip netns exec ns-vlan-a route -n
ip netns exec ns-vlan-a ip route


# 在ns-vlan-b中配置ip和路由
ip netns exec ns-vlan-b ip addr add 172.16.30.21/24 dev veth-b.100
ip netns exec ns-vlan-b ip addr add 172.16.30.22/24 dev veth-b.200
ip netns exec ns-vlan-b ip link show type vlan
ip netns exec ns-vlan-b ip a show type vlan
ip netns exec ns-vlan-b route add 172.16.30.1 dev veth-b.100
ip netns exec ns-vlan-b route add 172.16.30.2 dev veth-b.200
ip netns exec ns-vlan-b route -n
ip netns exec ns-vlan-b ip route



# 在ns-vlan-br中给vlan-br添加设备
ip netns exec ns-vlan-br brctl addif vlan-br veth-br-a
ip netns exec ns-vlan-br brctl addif vlan-br veth-br-b
ip netns exec ns-vlan-br brctl show



# ping
## 能ping通
ip netns exec ns-vlan-a ping -c3 172.16.30.21 -i veth-a.100
## 不能ping通
ip netns exec ns-vlan-a ping -c3 172.16.30.22 -i veth-a.100
## 能ping通
ip netns exec ns-vlan-a ping -c3 172.16.30.22 -i veth-a.100
## 不能ping通
ip netns exec ns-vlan-a ping -c3 172.16.30.22 -i veth-a.200
```



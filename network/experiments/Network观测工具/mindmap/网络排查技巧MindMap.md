---

mindmap-plugin: basic

---

# 网络排查

## 基础概念

### 分层模型

#### OSI的七层模型

#### TCP/IP的四层模型

#### TCP/IP的五层模型

#### 为什么 TCP/IP 还有四层和五层模型这两种说法呢？

#### 每层的作用

### TCP Stream

#### 五元组：传输协议类型、源IP、源端口、目的IP、目的端口

#### 四元组：源IP、源端口、目的IP、目的端口

### 消息类型

#### packet: 报文

#### frame: 帧

#### 分组: IP层报文；是狭义的 packet

#### 段: TCP segment；即TCP报文

#### 数据报: Datagram

## 应用层

### HTTP

#### 浏览器

##### 找到有问题的服务端 IP

###### 排查公网的访问问题

##### 辅助排查网页慢的问题

###### 时间统计功能

##### 解决失效 Cookie 带来的问题

## 表示层和会话层

### 检查TLS证书

#### 浏览器的地址栏

##### Connection is secure 按钮

##### Certificate is valid 按钮

#### 浏览器中开发者工具的 Security 菜单

##### 查看更为详细的 TLS 信息

###### 协议版本

###### 密钥交换算法

###### 证书有效期

### 检查TLS 握手、密钥交换、密文传输等

#### tcpdump

#### Wireshark

## 传输层

### 路径可达性测试

#### telnet

##### telnet www\.baidu\.com 443

#### nc

##### nc -w 2 -zv www\.baidu\.com 443

#### ECMP

##### ECMP的路径选择策略

###### 基于哈希的转发机制

###### 当某个中间节点故障时用nc命令排查

##### ECMP配合BGP/OSPF的使用场景

### 查看当前连接状况

#### netstat

##### netstat -ant

### 查看当前连接的传输速率

#### iftop

### 查看丢包和乱序等的统计

#### netstat

##### netstat -s

##### watch --diff netstat -s

#### ss

##### ss -s

## 网络层

### 查看网络路径状况

#### ping

#### traceroute

##### traceroute www\.baidu\.com

##### traceroute www\.baidu\.com -I

#### mtr

##### mtr www\.baidu\.com -r -c 10

### 查看路由

#### route

##### route -n

#### netstat

##### netstat -r

#### ip

##### ip route

## 数据链路层和物理层

### 问题直接体现在网络层和传输层

### 一般是专职的网络团队在负责

### ethtool工具
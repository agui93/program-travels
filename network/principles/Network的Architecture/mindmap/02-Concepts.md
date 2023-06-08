---

mindmap-plugin: basic

---

# Network Concepts

## Networks and Routing

### networks

#### a network

##### network protocol addresses

#### smaller networks

##### isolated locally

##### more efficient usage

#### transmission

##### unicast

##### multicast

##### broadcast

### routing

#### IP header

### firewalls

## Protocols

### communication between systems and devices

### transmit routable messages by encapsulation of payload data

### different performance characteristics

### system tunable parameters

#### buffer sizes

#### algorithms

#### various timers

## Encapsulation

### payload

### head

### footer

## Packet Size

### performance

#### throughput

#### packet overheads

#### latency

### MTU

#### 1,500 MTU default

#### balance factors

##### NIC buffer cost

##### transmission latency

#### jumbo frames

##### Ethernet

##### approximately 9,000 bytes

##### confluence

###### older network hardware
- an ICMP “can’t fragment” error

###### misconfigured firewalls
- blocking all ICMP

##### 1,500 MTU default

### The performance of 1,500 MTU frames

#### TCP offload

#### large segment offload

#### narrowed the gap between 1,500 and 9,000 MTU network performance

## Latency

### Name Resolution Latency

#### OS cache

#### DNS resolution

#### use IP address directly

### Ping Latency

#### ICMP echo

##### not exactly reflect round-trip

##### with a different priority by routers

#### between

##### hosts

##### hops

### Connection Latency

#### TCP connection latency

#### TCP handshake time

##### TCP SYN packet

##### corresponding SYN-ACK

##### backlog

##### timer-based retransmit of the SYN

### First-Byte Latency

#### include: the time for the remote host to accept a connection

#### include: time to process the request (e.g., TCP backlog)

#### include:  to schedule the server (CPU scheduler latency)

### Round-Trip Time

#### include: the time for the remote host to accept a connectionthe signal propagation time

#### include: the processing time at each network hop

### Connection Life Span

## Buffers

### effects of mitigation

#### higher round-trip times

#### blocking and waiting for an acknowledgment

### TCP

#### a sliding send window

#### congestion avoidance

#### end-to-end arguments

#### socket buffers

#### applications own buffers

##### to aggregate data before sending

### buffers of switches and routers

#### throughput

#### bufferbloat

### end-to-end arguments

## Connection Backlog

### buffer of the initial connection requests

### TCP backlog

#### queue SYN requests

#### drop SYN packets

#### tunable

##### the listen(2) syscall

##### system-wide limits

## Interface Negotiation

### autonegotiated

### Bandwidth

#### lower speeds if needed

### Duplex

#### Full-duplex

#### Half-duplex

## Congestion Avoidance

### networks become congested

### Ethernet: pause frames

### IP ECN:  Explicit Congestion Notification

### TCP congestion control algorithms

## Utilization

### calculation: not straightforward

### full duplex: measured for each direction

#### asymmetric

#### transmit-heavy for servers

#### receive-heavy fro clients

### only measurement  of packets, not bytes

#### packet size : vary greatly

#### not possible: throughput-based utilization

## Local Connections

### IP sockets technique of IPC

### UDS: Unix domain sockets

#### better for local connections

#### bypass the kernel TCP/IP stack
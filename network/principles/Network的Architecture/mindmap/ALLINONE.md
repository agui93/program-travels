---

mindmap-plugin: basic

---

# Network-ALL

## Terminology

### Interface

### Packet

### Frame

### Socket

### Bandwidth

### Throughput

### Latency

## Models

### Network Interface

#### mapped to physical network port

#### an os endpoint

### Network Controller

#### NIC: network interface card

#### Ports

##### connected to Physical Network

##### Transmit

##### Receive

#### Network Controller

##### I/O  Transport

##### a microprocessor

##### Between

###### Ports

###### System I/O  Transport

### Network Protocol Stacks

#### TCP/IP

##### Application

###### Http

###### DNS

###### SSL、TLS

###### RPC

##### Transport

###### TCP

###### UDP

##### Internet

###### IPv4

###### IPv6

##### Data Link

###### Ehternet

##### Physical

###### copper/fiber

#### OSI Model

## Concepts

### Networks and Routing

#### networks

##### a network

###### network protocol addresses

##### smaller networks

###### isolated locally

###### more efficient usage

##### transmission

###### unicast

###### multicast

###### broadcast

#### routing

##### IP header

#### firewalls

### Protocols

#### communication between systems and devices

#### transmit routable messages by encapsulation of payload data

#### different performance characteristics

#### system tunable parameters

##### buffer sizes

##### algorithms

##### various timers

### Encapsulation

#### payload

#### head

#### footer

### Packet Size

#### performance

##### throughput

##### packet overheads

##### latency

#### MTU

##### 1,500 MTU default

##### balance factors

###### NIC buffer cost

###### transmission latency

##### jumbo frames

###### Ethernet

###### approximately 9,000 bytes

###### confluence
- older network hardware
   - an ICMP “can’t fragment” error
- misconfigured firewalls
   - blocking all ICMP

###### 1,500 MTU default

#### The performance of 1,500 MTU frames

##### TCP offload

##### large segment offload

##### narrowed the gap between 1,500 and 9,000 MTU network performance

### Latency

#### Name Resolution Latency

##### OS cache

##### DNS resolution

##### use IP address directly

#### Ping Latency

##### ICMP echo

###### not exactly reflect round-trip

###### with a different priority by routers

##### between

###### hosts

###### hops

#### Connection Latency

##### TCP connection latency

##### TCP handshake time

###### TCP SYN packet

###### corresponding SYN-ACK

###### backlog

###### timer-based retransmit of the SYN

#### First-Byte Latency

##### include: the time for the remote host to accept a connection

##### include: time to process the request (e.g., TCP backlog)

##### include:  to schedule the server (CPU scheduler latency)

#### Round-Trip Time

##### include: the time for the remote host to accept a connectionthe signal propagation time

##### include: the processing time at each network hop

#### Connection Life Span

### Buffers

#### effects of mitigation

##### higher round-trip times

##### blocking and waiting for an acknowledgment

#### TCP

##### a sliding send window

##### congestion avoidance

##### end-to-end arguments

##### socket buffers

##### applications own buffers

###### to aggregate data before sending

#### buffers of switches and routers

##### throughput

##### bufferbloat

#### end-to-end arguments

### Connection Backlog

#### buffer of the initial connection requests

#### TCP backlog

##### queue SYN requests

##### drop SYN packets

##### tunable

###### the listen(2) syscall

###### system-wide limits

### Interface Negotiation

#### autonegotiated

#### Bandwidth

##### lower speeds if needed

#### Duplex

##### Full-duplex

##### Half-duplex

### Congestion Avoidance

#### networks become congested

#### Ethernet: pause frames

#### IP ECN:  Explicit Congestion Notification

#### TCP congestion control algorithms

### Utilization

#### calculation: not straightforward

#### full duplex: measured for each direction

##### asymmetric

##### transmit-heavy for servers

##### receive-heavy fro clients

#### only measurement  of packets, not bytes

##### packet size : vary greatly

##### not possible: throughput-based utilization

### Local Connections

#### IP sockets technique of IPC

#### UDS: Unix domain sockets

##### better for local connections

##### bypass the kernel TCP/IP stack

## Architecture

### Protocols

#### IP

##### IPv4

##### IPv6

##### DSCP: Differentiated Services Code Point

###### telephony

###### broadcast video

###### low-latency data

###### high-throughput data

###### low-priority data

##### ECN: Explicit Congestion Notification

###### signal the ECN bit in the IP header

###### throttle transmission: echo this signal back to the sender

###### congestion avoidance: without incurring the penalty of packet drops

#### TCP

##### performance features

###### Sliding window

###### Congestion avoidance

###### Slow-start

###### Selective acknowledgments

###### Fast retransmit

###### Fast recovery

###### TCP fast open

###### TCP timestamps

###### TCP SYN cookies

##### Three-Way Handshake

###### passive and active /  listen and connect

###### three way
- SYN
- SYN,ACK
- ACK

##### States and Timers

###### LISTEN

###### SYN-SENT

###### SYN-RECEIVED

###### ESTABLISHED
- Performance analysis
- keep alive timer: two hours

###### FIN-WAIT-1

###### FIN-WAIT-2

###### CLOSE-WAIT

###### CLOSING

###### LAST-ACK

###### TIME-WAIT
- two minutes: may be tuned
- issue: port exhaustion

###### CLOSED

##### Duplicate ACK Detection

###### work follows

###### used by fast retransmit

###### used by fast recovery

###### used by congestion avoidance

##### Retransmits

###### Timer-based retransmits

###### Fast retransmits

###### Tail Loss Probe

###### Congestion control: throttle throughput

##### Congestion Controls

###### Reno
- Triple duplicate ACKs trigger
- halving of the congestion window
- halving of the slow-start threshold
- fast retransmit
- fast recovery

###### Tahoe
- Triple duplicate ACKs trigger
- fast retransmit
- halving the slow-start threshold
- congestion window set to one MSS  and slow-start state

###### CUBIC
- a cubic function: scale the window
- a “hybrid start” function to exit slow start

###### BBR
- an explicit model of the network path characteristics (RTT and bandwidth)

###### DCTCP
- DataCenter TCP relies on switches configured to emit ECN mark
- unsuitable for deployment across the Internet
- improve performance significantly: a suitably configured controlled environment

###### BPF
- support for developing new congestion control algorithms
- Linux 5.6

##### Nagle

###### reduce the number of small packets

###### delay transmission

###### socket option to disable Nagle

##### Delayed ACKs

###### delay the sending of ACKs

###### tunable: disable

##### SACK, FACK, and RACK

###### SACK
- selective acknowledgment

###### FACK
- forward acknowledgments
- Linux: supported by default

###### RACK
- Recent ACKnowledgment
- now called RACK-TLP

##### Initial Window (IW)

###### Linux default: 10 packets, aka IW10

###### risk of Larger IWs

###### For short flows: HTTP connections

#### UDP

##### datagrams

##### performance

###### Simplicity

###### Statelessness

###### No retransmits

###### lack of congestion control

##### unreliable

###### data missing

###### data received out of order

#### QUIC and HTTP/3

##### built on UDP

##### alternative to TCP: optimized for HTTP and TLS

##### features

### Hardware

#### Interfafces

##### Physical network interfaces: on the attached network

##### frames: send and receive

##### Ethernet

##### Interface utilization: the current throughput divided by the current negotiated bandwidth

##### Interface types are based on layer 2 standards

#### Controllers

##### via controllers: Physical network interfaces are provided to the system

##### Controllers are driven by microprocessors and are attached to the system via an I/O transport (e.g., PCI).

#### Switches

##### a dedicated communication path between any two connected hosts

##### replace hubs

###### collision

###### CSMA/CD algorithm

##### rate transitions

#### Routers

##### deliver packets between networks

##### determine efficient delivery paths

###### use network protocols

###### use routing tables

##### include buffers and microprocessors

##### path dynamically

##### advanced real-time monitoring tools

###### check all routers

###### check other network components involved

##### rate transitions

#### Firewalls

##### a configured rule set: permit only authorized communications

##### security

##### may be a performance bottleneck

##### a nuisance during performance testing

##### eBPF

#### Others

##### hubs

##### bridges

##### repeaters

##### modems

### Software

#### Network Stack

##### Generic network stack

##### Linux network stack

###### a core kernel component

###### device drivers: additional modules

###### Linux network stack Figure

#### TCP performance details

##### TCP Connection Queues

###### the SYN backlog

###### the listen backlog

##### TCP Buffering

###### Socket Send Buffer for TCP

###### Socket Receive Buffer for TCP

###### is tunable

##### Segmentation Offload: GSO and TSO

##### Queueing Discipline

###### an optional layer
- managing traffic classification(tc)
- scheduling
- manipulation
- filtering
- shaping

###### qdiscs: queueing discipline algorithms
- tc command
- man -k tc
- default qdisc: pfifo_fast

###### BPF
- programs
   - BPF_PROG_TYPE_SCHED_CLS
   - BPF_PROG_TYPE_SCHED_ACT
- enhance the capabilities of this layer with the programs
   - be attached to kernel ingress and egress points
   - packet filtering
   - mangling
   - forwarding

#### Network Device Drivers

##### a ring buffer

###### between kernel memory and the NIC

###### for sending and receiving packets

##### interrupt coalescing mode

###### either a timer (polling)

###### or a certain number of packets

##### NAPI

###### Linux kernel uses a new API framework

###### an interrupt mitigation technique
- for low packet rates
- for high packet rates

###### Packet throttling

###### Interface scheduling

###### Support for the SO_BUSY_POLL socket option

##### virtual machine networking

###### Coalescing: be especially important

#### NIC Send and Receive

##### For sent packets

###### NIC is notified

###### DMA and kernel memory

###### transmit descriptors

##### For received packets

###### DMA and kernel ring-buffer memory

###### notify the kernel
- interrupt
- or allow coalescing

#### CPU Scaling

##### RSS: Receive Side Scaling

##### RPS: Receive Packet Steering

##### RFS: Receive Flow Steering

##### Accelerated Receive Flow Steering

##### XPS: Transmit Packet Steering

#### Kernel Bypass

##### bypass the kernel network stack

##### DPDK

##### XDP

#### Other Optimizations

##### TCP send path

##### Socket

###### Send Buffer

##### TCP

###### Pacing

###### TSO

###### Congestion Control

###### Nagle

###### TSQ

##### IP/Net

###### qdisc

###### GSO

###### BQL

##### NIC

###### TSO
---

mindmap-plugin: basic

---

# Methodologies

## Tools Method

### iterating over available tools

### overlook issues

### may be time-consuming

## Performance Monitoring

### over time

#### identify active issues

#### identify patterns of behavior

### key metrics

#### Throughput

#### Connections

#### Errors

#### TCP retransmits

#### TCP out-of-order packets

## USE Method

### Utilization

#### calculated (resource controls)

### Saturation

#### difficult to measure

#### measure by application

#### linux overruns

#### TCP Retransmits

### Errors

#### checked first

### How To Measure?

## Static Performance Tuning

### examine static configurations

### aspects of static configurations

## Workload Characterization

### Network interface throughput

### Network interface IOPS

### TCP connection rate

### Advanced Workload Characterization/Checklist

## Latency analysis

### How to measure

### Name resolution latency

### Ping latency

### TCP connection initialization latency

### TCP first-byte latency

### TCP retransmits

### TCP TIME_WAIT latency

### Connection/session lifespan

### System call send/ receive latency

### System call connect latency

### Network round-trip time

### Interrupt latency

### Inter-stack latency

## TCP Analysis

### Usage of TCP (socket) send/receive buffers

### Usage of TCP backlog queues

### Kernel drops due to the backlog queue being full

### Congestion window size, including zero-size advertisements

### SYNs received during a TCP TIME_WAIT interval

#### reuse

#### recycle connections quickly

## Resource Controls

### Network bandwidth limits

#### applied by the kernel

#### for different protocols

#### for different applications

### IP quality of service (QoS)

#### The prioritization of network traffic

#### network components

##### routers

##### IP header: ToS bits

### Packet latency

#### tc-netem

## Micro-Benchmarking

### tools

#### iperf

#### netperf

### factors

#### Direction: Send or Receive

#### Protocol: TCP or UDP, and port

#### Number of threads

#### Buffer size

#### Interface MTU size

## Packet Sniffing

### be expensive to perform in terms of CPU and storage overhead

### filtering expression

### packet details
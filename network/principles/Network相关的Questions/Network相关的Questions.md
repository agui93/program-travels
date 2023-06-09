
- Network Performance Questions
	- What protocol requests are occurring? By user stack trace? By latency?
	- What application level I/O is occurring? With protocol details?
	- What direct network I/O is occurring (for example, NFS client)?
	-  What socket I/O is occurring, throughput and IOPS? By process and stack trace?
	-  What socket connections are being created/accepted?
	-  Is the socket layer returning errors? Why?
	-  What transport I/O is occurring? TCP vs. UDP?
	-  What raw network I/O is occurring? ICMP by type?
	-  What IP I/O is occurring? By size? By source/destination?
	-  What network interface I/O is occurring? By size?
	-  What network devices are still using dld?
	-  What is the frequency of driver calls?
	-  Are drivers polling interfaces or waiting for interrupts?
	-  What is the network stack latency?
	-  What is the driver interface stack latency?
- Show providers of interest when tracing network stack I/O?
- Count Web server–received packets by client IP address
- Socket
	- Socket Accepts by Process Name
	- Socket Connections by Process and User Stack Trace
	- Socket Read, Write, Send, Recv I/O Count by System Call
	- Socket Read (Write/Send/Recv) I/O Count by Process Name
	- Socket Reads (Write/Send/Recv) I/O Count by System Call and Process Name
	- Socket Reads (Write/Send/Recv) I/O Count by Process and User Stack Trace
	- Socket Write Bytes by Process Name
	- Socket Read Bytes by Process Name
	- Socket Write I/O Size Distribution by Process Name
- IP 
	- Received IP packets by host address
	- IP send payload size distribution by destination
- TCP
	- Watch inbound TCP connections by remote address (either)
	- Inbound TCP connections by remote address summary
	- Inbound TCP connections by local port summary
	- Who is connecting to what
	- Who isn’t connecting to what
	- What am I connecting to
	- TCP Outbound connections by remote port summary
	- TCP received packets by remote address summary (either)
	- TCP sent packets by remote address summary (either)
	- TCP received packets by local port summary
	- TCP send packets by remote port summary
	- TCP payload bytes for TCP send
	- TCP events by type summary
	- TCP count established  connections by port number
	- TCP connection latency
	- TCP state changes along with delta times
	- IP payload bytes for TCP send, size distribution by destination address
- UDP
	- UDP received packets by remote address summary (either)
	- UDP sent packets by remote port summary
- questions
	- What outbound connections are occurring? To which server and port? connect() time?
		- Why are applications performing connections, stack trace?
	- What inbound connections are being established?
	- Connection errors
	- What client socket I/O is occurring, read and write bytes?
		- By which process? What is performing the most socket I/O?
	- What server socket I/O is occurring, read and write bytes, by which processes? Client?
	    - Which process is performing the most socket I/O?
	- Socket I/O errors
	- Who ends connections, and why? User-level stack trace?
	- What is the duration of connections, with server and port details?
	- What is the time from connect to the first payload byte from the server?
	- What is the time from accept to the first payload byte from the client?
- MIB
	- SNMP MIB event count
	- IP MIB event statistics
	- IP MIB event statistics with kernel function:
	- TCP MIB event statistics
	- TCP MIB event statistics with kernel function
	- UDP MIB event statistics
	- ICMP MIB event trace
	- ICMP MIB event by kernel stack trace
















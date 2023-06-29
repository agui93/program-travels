# 镜像: k8strials.harbor.com/library/ubuntu-net-base:01
FROM ubuntu:22.04
RUN apt-get -y update && apt-get install -y iproute2 iputils-arping net-tools tcpdump curl telnet iputils-tracepath traceroute

RUN apt-get -y install openbsd-inetd 
RUN echo "discard     stream  tcp nowait  root    internal \ndiscard     dgram   udp wait    root    internal \ndaytime     stream  tcp nowait  root    internal \ntime        stream  tcp nowait  root    internal \necho        stream  tcp nowait  root    internal \n" >> /etc/inetd.conf 

RUN apt-get -y install vim openssh-server iputils-ping dnsutils
RUN apt-get -y install netcat
RUN mkdir /run/sshd

RUN echo "/etc/init.d/openbsd-inetd start \n/usr/sbin/sshd -D \n" > /start.sh
RUN chmod u+x /start.sh 

CMD ["/bin/bash", "-c", "/start.sh"]


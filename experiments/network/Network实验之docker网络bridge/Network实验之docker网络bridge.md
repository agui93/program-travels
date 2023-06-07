
# 实验准备

- docker network 
	- docker network bridge
		- docker默认使用bridge: docker0
	- 网络原理
		- `veth`
		- `bridge`
		- `iptables`
		- `ip-route`


# 实验过程和实验结果
- docker network bridge
	- `docker network ls`
		- ![docker_bridge_default_docker0_network_ls.png](attachments/docker_bridge_default_docker0_network_ls.png)
	- `ip addr show type bridge`
		- ![docker_bridge_default_docker0_ip_show.png](attachments/docker_bridge_default_docker0_ip_show.png)
	- `iptables -t nat -L -n -v`
		- ![docker_bridge_default_docker0_iptables_nat.png](attachments/docker_bridge_default_docker0_iptables_nat.png)
	- `iptables -t filter -L -n -v`
		- ![docker_bridge_default_docker0_iptables_filter.png](attachments/docker_bridge_default_docker0_iptables_filter.png)
		- ![docker_bridge_default_docker0_iptables_mangle.png](attachments/docker_bridge_default_docker0_iptables_mangle.png)
	- `brctl show docker0`
		- ![docker_bridge_default_docker0_brctl_show.png](attachments/docker_bridge_default_docker0_brctl_show.png)
	- `docker network inspect bridge`
		- ![docker_bridge_default_docker0_inspect.png](attachments/docker_bridge_default_docker0_inspect.png)
	- `route -n`
		- ![docker_bridge_default_docker0_route.png](attachments/docker_bridge_default_docker0_route.png)
	- `docker run -itd --name test1 alpine`
		- `docker inspect test1 | jq '.[].NetworkSettings'`
			- ![docker_bridge_container-test1_inspect_network.png](attachments/docker_bridge_container-test1_inspect_network.png)
		- container: ip-route and veth
			- ![docker_bridge_container-test1_container-veth.png](attachments/docker_bridge_container-test1_container-veth.png)
			- ![docker_bridge_container-test1_host-veth.png](attachments/docker_bridge_container-test1_host-veth.png)
	- `docker run -itd --name test2 alpine`
		- `docker inspect test2 | jq '.[].NetworkSettings'`
			- ![docker_bridge_inspect_network_container-test2.png](attachments/docker_bridge_inspect_network_container-test2.png)
			- ![docker_bridge_container-test2_host_veth.png](attachments/docker_bridge_container-test2_host_veth.png)
	- `docker run --name nginx-demo -itd  -p 8080:80 nginx:latest`
		- `docker inspect nginx-demo | jq '.[].NetworkSettings'`
			- ![docker_bridge_inspect_container_after_port-mapping.png](attachments/docker_bridge_inspect_container_after_port-mapping.png)
	- `iptables -t nat -L -n -v`
			- ![docker_bridge_iptalbes_nat_after_port-mapping.png](attachments/docker_bridge_iptalbes_nat_after_port-mapping.png)
			- `iptables-save > bak.iptables`
			- `cat bak.iptables`
				- ![docker_bridge_bak_iptables.png](attachments/docker_bridge_bak_iptables.png)





# 安装虚拟机

```bash
# 安装虚拟机(jammy版本,ubuntu 22.04, 内核版本是5.15)
multipass launch --mem 4G --disk 24G --cpus 2 --network en0  --network name=bridge0,mode=manual --network name=bridge0,mode=manual --name ebpfvm

# 进入虚拟机: update
sudo -s
apt update
```



# 安装bcc

```bash
# 安装教程: https://github.com/iovisor/bcc/blob/master/INSTALL.md#ubuntu---source
# 系统版本: uname -a : Linux ebpfvm 5.15.0-71-generic #78-Ubuntu SMP Tue Apr 18 09:00:29 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

# 安装基本软件
apt install -y zip bison build-essential cmake flex git libedit-dev \
  libllvm14 llvm-14-dev libclang-14-dev python3 zlib1g-dev libelf-dev libfl-dev python3-setuptools \
  liblzma-dev libdebuginfod-dev arping netperf iperf

# 下载软件(基于源码master分支编译会出现兼容问题)
wget https://github.com/iovisor/bcc/releases/download/v0.27.0/bcc-src-with-submodule.tar.gz

# 编译安装 
mkdir bcc/build; cd bcc/build
cmake ..
make
make install
cmake -DPYTHON_CMD=python3 ..
pushd src/python/
make
make install
popd

# 验证
cd /usr/share/bcc/tools
python3 execsnoop
```



# 安装bpfstrace

```bash
# 教程: https://installati.one/install-bpftrace-ubuntu-22-04/

# 安装
apt-get -y install bpftrace

# Uninstall bpftrace And Its Dependencies
# apt-get -y autoremove bpftrace

# Remove bpftrace Configurations and Data
# apt-get -y purge bpftrace

# Remove bpftrace configuration, data, and all of its dependencies
# apt-get -y autoremove --purge bpftrace


# 安装bpftrace-dbgsym, 教程 : https://wiki.ubuntu.com/Debug%20Symbol%20Packages
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | tee -a /etc/apt/sources.list.d/ddebs.list

apt-get install ubuntu-dbgsym-keyring
apt-get update
apt-get install bpftrace-dbgsym


# 下载bpfstrace(基于0.14.1无兼容问题，更高版本的bpfstrace会出现兼容问题)
wget https://github.com/iovisor/bpftrace/archive/refs/tags/v0.14.1.tar.gz
tar -zxvf v0.14.0.tar.gz
cd bpftrace-0.14.1/tools/

# 验证
bpftrace -e 'BEGIN { printf("hello\n"); }'
./opensnoop.bt 
./tcpconnect.bt
```



当安装bpfstrace依赖的kernel-devel涉及到兼容问题时
```bash
# 教程: https://www.linuxcapable.com/how-to-install-ubuntu-mainline-kernel-installer-on-ubuntu-linux/

# 安装命令
add-apt-repository ppa:cappelikan/ppa -y
apt update
apt install mainline -y

# display a list of available mainline kernel versions, release dates, and download sizes
mainline --list

# display a list of all the kernel versions currently installed on your system, along with their release dates and download sizes
mainline --list-installed


```

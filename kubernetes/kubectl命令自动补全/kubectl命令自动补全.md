

# 安装kubectl

[在 Linux 系统中安装并设置 kubectl](https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/)
```bash
curl -LO https://dl.k8s.io/release/v1.23.3/bin/linux/amd64/kubectl 
curl -LO "https://dl.k8s.io/v1.23.3/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```


# 命令自动补全
```bash
yum install bash-completion -y
# 或者
apt install bash-completion -y

echo ''  >> ~/.bashrc
echo 'source /usr/share/bash-completion/bash_completion' >> ~/.bashrc
echo ''  >> ~/.bashrc

kubectl completion bash |tee /etc/bash_completion.d/kubectl > /dev/null
chmod a+r /etc/bash_completion.d/kubectl
source ~/.bashrc
```
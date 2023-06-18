





# Helm简介


- [helm github source](https://github.com/helm/helm)
- [helm docs](https://helm.sh/)
- [helm zh docs](https://helm.sh/zh/docs/)


- Concepts
	- Chart: A Chart is a Helm package.
	- Repository: A Repository is the place where charts can be collected and shared.
	- Release: A Release is an instance of a chart running in a Kubernetes cluster










# 安装Helm Client

- [install help doc](https://helm.sh/docs/intro/install/)
- [helm releases download](https://github.com/helm/helm/releases)

```shell
# 安装helm  
wget https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz
tar -zxvf helm-v3.11.1-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm


# 使用k8s
cp config ~/.kube/
chmod g-rw ~/.kube/config
chmod o-r ~/.kube/config
helm list -A
```







# 使用Helm






```shell
# helm help text
helm -h

# find charts
helm search -h
# display information about a chart
helm show -h
# create a chart
helm create -h
# runs a series of tests to verify that the chart is well-formed
helm lint -h
# packages a chart into a versioned chart archive file
helm package -h


# add, remove, list, and index chart repositories
helm repo -h

# list all of the releases for a specified namespace 
helm list -h
# track a release's state
helm status -h
# get extended information about the release
helm get -h

# install a package (override values by -f or --set)
# 注意: 当安装release后，Deployment类型的资源会部署
helm install -h
# uninstall a package
helm uninstall -h
# upgrades a release to a new version of a chart
helm upgrade -h
# rolls back a release to a previous revision
helm rollback -h
```








```Shell
# see what has been released
helm list
helm list -A

# uninstall a release
helm uninstall release-name-xxxx

# upgrades a release to a new version of a chart
# if a release by this name doesn't already exist, run an install
helm upgrade --install --namespace namespace-name-xxx   release-name-yyy    chart-name-zzz --set  replicas=2 --wait
```





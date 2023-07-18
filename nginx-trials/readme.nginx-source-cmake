
使用cmake编译nginx源码，使用clion阅读和调试源码

```bash
tar -zxvf nginx-source-cmake.tar.gz

cd nginx-source-cmake/nginx-source-v1.17.3/
rm -rf .git/

mv ../cmake   auto/
sed -i 's/auto\/make/auto\/cmake/g' auto/configure 

baseDir=$(pwd) && echo ${baseDir}
mkdir -p ${baseDir}/workdir/logs
cp -r conf ${baseDir}/workdir/

./auto/configure   --builddir=${baseDir}  --prefix=${baseDir}/workdir --without-pcre  --without-http_rewrite_module


mkdir cmake-build && cd cmake-build 
cmake .. && make
./nginx -t

nginx 
ps aux|grep nginx
```



### 编译镜像

本镜像只支持32/64位 x86 架构机器，不支持ARM等芯片架构。


### 环境

* ubuntu 24.04
* JDK 1.8
* maven 3.9
* python 3.11
* MySQL5.7
* Tomcat 9
* Redis

### 使用方法

在 Dockerfile 所在路径下：

``` shell
docker buildx build . -t web_server

docker run -d --name web_server -it web_server:latest /bin/bash
```

### 依赖软件包
* jdk-8u401-linux-x64.tar.gz
* apache-zookeeper-3.7.1-bin.tar.gz
* apache-tomcat-9.0.89.tar.gz
* mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz
* apache-maven-3.9.7-bin.tar.gz
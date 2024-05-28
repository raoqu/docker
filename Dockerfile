FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG=en_US.UTF-8

# python 3.11 and pip 3.11
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y net-tools && \
    apt-get install -y curl && \
    apt-get install -y python3.11 python3.11-dev && \
    apt-get install -y python3.11-venv python3.11-distutils && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.11 get-pip.py && \
    rm get-pip.py && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.11 1 

RUN pip install flask -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install flask_socketio -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY container_files/jdk-8u401-linux-x64.tar.gz /root/jdk-8u401-linux-x64.tar.gz
COPY container_files/apache-zookeeper-3.7.1-bin.tar.gz /root/apache-zookeeper-3.7.1-bin.tar.gz
COPY container_files/apache-tomcat-9.0.89.tar.gz /root/apache-tomcat-9.0.89.tar.gz
COPY container_files/mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz /root/mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz
COPY container_files/apache-maven-3.9.7-bin.tar.gz /root/apache-maven-3.9.7-bin.tar.gz

ENV MYSQL_ROOT_PASSWORD=mysql

RUN apt-get install -y redis-server && \
  apt-get install -q -y inetutils-ping 

RUN cd /root && \
  tar -xzf jdk-8u401-linux-x64.tar.gz && \
  mv jdk1.8.0_401 /usr/local && \
  rm jdk-8u401-linux-x64.tar.gz && \
  \
  tar -xzf apache-zookeeper-3.7.1-bin.tar.gz && \
  mv apache-zookeeper-3.7.1-bin /opt/zookeeper && \
  rm apache-zookeeper-3.7.1-bin.tar.gz && \
  \
  tar -xzf apache-tomcat-9.0.89.tar.gz && \
  mv apache-tomcat-9.0.89 /opt/tomcat1 && \
  cp -rf /opt/tomcat1 /opt/tomcat2 && \
  cp -rf /opt/tomcat1 /opt/tomcat3 && \
  rm apache-tomcat-9.0.89.tar.gz
  
RUN cd /root && tar -xzf mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz && \
  mv mysql-5.7.43-linux-glibc2.12-x86_64 /usr/local/mysql && \
  groupadd mysql && \
  useradd -r -g mysql mysql && \
  chown -R mysql:mysql /usr/local/mysql && \
  apt-get install -y libaio1t64 && \
  apt-get install -y libnuma1 && \
  ln -s /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1 && \
  ln -s /usr/lib/x86_64-linux-gnu/libncursesw.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5 && \
  ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5 && \
  /usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data > mysql_pass.txt 2>&1 && \
  cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql && \
  update-rc.d mysql defaults && \
  ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql && \
  rm mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz

COPY scripts/start-services.sh  /usr/local/bin/start-services.sh
COPY scripts/web.py /root/web.py
COPY scripts/templates/index.html /root/templates/index.html
COPY scripts/options.txt /root/options.txt
COPY scripts/init_mysql_pass.py /root/init_mysql_pass.py
COPY scripts/change_pass.sql /root/change_pass.sql
# COPY files/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources

RUN cd /root && tar -xzf apache-maven-3.9.7-bin.tar.gz && \
mv apache-maven-3.9.7 /opt/maven && \
rm apache-maven-3.9.7-bin.tar.gz && \
\
chmod +x /usr/local/bin/start-services.sh

ENV JAVA_HOME=/usr/local/jdk1.8.0_401
ENV PATH=$JAVA_HOME/bin:$PATH

EXPOSE 3306 6379 2181 8080 5000

CMD ["/bin/bash"]
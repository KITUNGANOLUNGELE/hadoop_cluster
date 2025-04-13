FROM ubuntu:focal
LABEL maintainer="Henock <kitunganohenock@gmail.com>"
#ne pas tenir compte des prompts
ENV DEBIAN_FRONTEND=noninteractive

#installation des differents paquets

RUN apt-get update && \
    apt-get install -y gnupg2 curl && \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | gpg --dearmor -o /usr/share/keyrings/tailscale-archive-keyring.gpg && \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list > /dev/null && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk openssh-server wget vim net-tools iputils-ping tailscale

#variabel d'environnement

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Installation de Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -xzf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# Préparer SSH
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N "" && \
    echo "root:root" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
# Port SSH
COPY setup/* /usr/local/hadoop/etc/hadoop/
EXPOSE 22 9864 9866 9867 9870 8088 8020 9000
# Start SSH à l’entrée
CMD ["/usr/sbin/sshd", "-D"]
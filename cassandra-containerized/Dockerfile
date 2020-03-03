FROM bitnami/cassandra:latest


#### <Install medusa> ####
## Install prerequisite packages ##
USER root
RUN apt-get update
RUN apt-get install -y python3-pip libffi-dev libssl-dev python3-dev
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-sdk

## Install medusa script ##
RUN pip3 install cassandra-medusa[GCS]

## Prepare medusa configuration folder ##
RUN mkdir -p /etc/medusa
COPY medusa/credentials.json /etc/medusa/
COPY medusa/medusa.ini /etc/medusa/
#### </Install medusa> ####


#### <Install and configure openssh-server with direct, key-based root access (DO NOT DO THIS ON ANY PRODUCTION ENVIRONMENT)> ####
## Install openssh-server ##
RUN apt-get install -y ssh openssh-client openssh-server
RUN mkdir -p /var/run/sshd
RUN echo 'root:123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

## Setup openssh autostart ##
#RUN systemctl enable ssh

## Setup key-based, passphrase-less ssh access to self ##
RUN apt-get install -y sshpass
COPY key_authorization/id_rsa /home/root/.ssh/
COPY key_authorization/id_rsa.pub /home/root/.ssh/
RUN mkdir -p /.ssh
COPY key_authorization/id_rsa /root/.ssh/
COPY key_authorization/id_rsa.pub /root/.ssh/
RUN service ssh restart && sshpass -p 123 ssh-copy-id -i /home/root/.ssh/id_rsa -o StrictHostKeyChecking=no root@localhost
#### </Install and configure openssh-server with direct, key-based root access (DO NOT DO THIS ON ANY PRODUCTION ENVIRONMENT)> ####


#### <Just some additional fun stuff for testing> ####
COPY scripts/dragonrat /home/root/
RUN echo "cat dragonrat" >> /home/root/.bashrc
#### </Just some additional fun stuff for testing> ####


#### <Install runtime configuration script> ####
RUN apt-get install -y netcat
COPY scripts/startvariousstuff.sh .
##Injecting our own bootup script into one of the scripts by bitnami
RUN echo "##### <custom script injection> #####" >> /concat_scripts && cat /startvariousstuff.sh >> /concat_scripts && echo "" >> /concat_scripts && echo "##### </custom script injection> #####" >> /concat_scripts && echo "" >> /concat_scripts && cat /run.sh >> concat_scripts && mv /concat_scripts /run.sh && chmod 755 /run.sh
#### </Install runtime configuration script> ####


#### <Install and configure graphite reporting> ####
#RUN apt install -y default-jre

ARG GraphiteNodeName
ARG GraphiteNodeColor

#RUN apt install -y default-jdk
#RUN export JAVA_HOME=/opt/bitnami/java/bin/java
#RUN export PATH=$PATH:/opt/bitnami/java/bin
#RUN export PATH=$PATH:/opt/bitnami/cassandra/bin

COPY graphite/graphite.yaml /bitnami/cassandra/conf/
RUN sed -i "s/<node_name_for_substitution>/$GraphiteNodeName/" /bitnami/cassandra/conf/graphite.yaml
RUN sed -i "s/<color_name_for_substitution>/$GraphiteNodeColor/" /bitnami/cassandra/conf/graphite.yaml
COPY graphite/cassandra-env.sh /bitnami/cassandra/conf/
COPY graphite/metrics-graphite-3.1.0.jar /opt/bitnami/cassandra/lib/
COPY scripts/customsetupscript.sh /docker-entrypoint-initdb.d

#COPY graphite/graphite.yaml /opt/bitnami/cassandra/conf/
#RUN sed -i "s/<node_name_for_substitution>/$GraphiteNodeName/" /opt/bitnami/cassandra/conf/graphite.yaml
#RUN sed -i "s/<color_name_for_substitution>/$GraphiteNodeColor/" /opt/bitnami/cassandra/conf/graphite.yaml
#COPY graphite/metrics-graphite-3.1.0.jar /opt/bitnami/cassandra/lib/
#RUN echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.metricsReporterConfigFile=graphite.yaml\"" >> /opt/bitnami/cassandra/conf/cassandra-env.sh

#COPY graphite/graphite.yaml .
#RUN sed -i "s/<node_name_for_substitution>/$GraphiteNodeName/" /graphite.yaml
#RUN sed -i "s/<color_name_for_substitution>/$GraphiteNodeColor/" /graphite.yaml
#RUN cat /graphite.yaml
#COPY graphite/metrics-graphite-3.1.0.jar /opt/bitnami/cassandra/lib/
#### </Install and configure graphite reporting> ####
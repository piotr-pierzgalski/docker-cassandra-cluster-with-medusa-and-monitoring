########## <Download missing apt-get packages in a separate build> ##########
FROM debian:stretch AS aptgetter
RUN apt-get update
WORKDIR /root/downloadfolder/
RUN apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
  --no-conflicts --no-breaks --no-replaces --no-enhances \
  --no-pre-depends "apt-transport-https" | grep "^\w")
########## </Download missing apt-get packages in a separate build> ##########

########## <Prepare apache cassandra image for further building> ##########
FROM cassandra:3.11.5
USER root

## Inject the missing packages into the apache cassandra image
COPY --from=aptgetter /root/downloadfolder/ /var/cache/apt/archives/
RUN cd /var/cache/apt/archives/ && ls
RUN dpkg -i /var/cache/apt/archives/*.deb 
#RUN apt-get update && apt-get install -y apt-transport-https
RUN apt-get update && apt-get install -y apt-utils alpine-pico curl sudo iputils-ping

## Remove unnecessary topology file (as per https://docs.datastax.com/en/dse/5.1/dse-admin/datastax_enterprise/operations/opsAddDCToCluster.html, this file should apparently not be present on new clusters that are using GossippingPropertyFileSnitch from the start)
RUN rm /etc/cassandra/cassandra-topology.properties
## Limit Cassandra's max heap size for development purposes
ARG Cassandra_MaxHeapSizeInMB

RUN sed -i 's/#MAX_HEAP_SIZE="4G"/MAX_HEAP_SIZE="'"${Cassandra_MaxHeapSizeInMB}"'M"/' /etc/cassandra/cassandra-env.sh
RUN sed -i 's/#HEAP_NEWSIZE="800M"/HEAP_NEWSIZE="200M"/' /etc/cassandra/cassandra-env.sh
RUN cat /etc/cassandra/cassandra-env.sh

## Specify the default directories in Cassandra's yaml explicitly for medusa-related purposes
#RUN sed -i 's,# hints_directory: /var/lib/cassandra/hints,hints_directory: /var/lib/cassandra/hints,' /etc/cassandra/cassandra.yaml
#RUN sed -i 's,# commitlog_directory: /var/lib/cassandra/commitlog,commitlog_directory: /var/lib/cassandra/commitlog,' /etc/cassandra/cassandra.yaml
#RUN sed -i 's,# saved_caches_directory: /var/lib/cassandra/saved_caches,saved_caches_directory: /var/lib/cassandra/saved_caches,' /etc/cassandra/cassandra.yaml
#RUN sed -i 's,# data_file_directories,data_file_directories,' /etc/cassandra/cassandra.yaml
#RUN sed -i 's,#     - /var/lib/cassandra/data,    - /var/lib/cassandra/data,' /etc/cassandra/cassandra.yaml


#COPY scripts/cqlshrc /etc/cassandra
########## </Prepare apache cassandra image for further building> ##########

########## <Install medusa> ##########
## Install prerequisite packages ##
USER root
RUN apt-get update
## Install Python3
RUN apt-get install -y python3-pip libffi-dev libssl-dev python3-dev
## Install Google cloud storage SDK
RUN apt-get update && apt-get install -y gnupg2
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-sdk

## Install medusa script ##
RUN pip3 install cassandra-medusa[GCS]
#RUN pip3 install https://github.com/thelastpickle/cassandra-medusa/archive/master.zip

## Prepare medusa configuration folder ##
RUN mkdir -p /etc/medusa
COPY medusa/credentials.json /etc/medusa/
COPY medusa/medusa.ini /etc/medusa/
########## </Install medusa> ##########


########## <Install and configure jmx prometheus reporting and node exporter to expose various node metrics for grafana dashboards> ##########
RUN apt-get install -y wget git
RUN wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

#Skipping node exporter
#RUN go get github.com/prometheus/node_exporter
#RUN cd ${GOPATH-$HOME/go}/src/github.com/prometheus/node_exporter && make && ./node_exporter -h

COPY prometheus/jmx_prometheus_javaagent-0.12.0.jar .
COPY prometheus/cassandra.yml .
RUN echo 'JVM_OPTS="$JVM_OPTS -javaagent:'//jmx_prometheus_javaagent-0.12.0.jar=7070://cassandra.yml'"' >> /etc/cassandra/cassandra-env.sh
########## </Install and configure jmx prometheus reporting for grafana> ##########


########## <Install and configure openssh-server with direct, key-based root access (DO NOT DO THIS ON ANY PRODUCTION ENVIRONMENT)> ##########
## Install openssh-server ##
RUN apt-get install -y ssh openssh-client openssh-server
RUN mkdir -p /var/run/sshd
RUN echo 'root:123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitUserEnvironment no/PermitUserEnvironment yes/' /etc/ssh/sshd_config
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

## Setup key-based, passphrase-less ssh access to self ##
RUN apt-get install -y sshpass
COPY key_authorization/id_rsa /home/root/.ssh/
COPY key_authorization/id_rsa.pub /home/root/.ssh/
RUN mkdir -p /.ssh
COPY key_authorization/id_rsa /root/.ssh/
COPY key_authorization/id_rsa.pub /root/.ssh/
RUN chmod 400 /root/.ssh/id_rsa
RUN service ssh restart && sshpass -p 123 ssh-copy-id -i /home/root/.ssh/id_rsa -o StrictHostKeyChecking=no root@localhost
########## </Install and configure openssh-server with direct, key-based root access (DO NOT DO THIS ON ANY PRODUCTION ENVIRONMENT)> ##########


########## <Just some additional fun stuff for testing> ##########
COPY scripts/dragonrat /etc
RUN cat /etc/dragonrat >> /etc/motd
########## </Just some additional fun stuff for testing> ##########


########## <Install runtime configuration script> ##########
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN env | grep _ >> /etc/environment

COPY scripts/startvariousstuff.sh .
CMD ["sh", "startvariousstuff.sh"]
########## </Install runtime configuration script> ##########
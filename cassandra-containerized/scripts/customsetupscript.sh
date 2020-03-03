echo "Setting up environment variables"

sudo su -

export JAVA_HOME=/opt/bitnami/java/bin/java
export PATH=$PATH:/opt/bitnami/java/bin
export PATH=$PATH:/opt/bitnami/cassandra/bin

echo "Exporting environment variables"
env | grep _ >> /etc/environment
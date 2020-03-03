echo "######### <Running custom script> #########"

echo $PATH
echo $JAVA_HOME
#env | grep _ >> /etc/environment

#echo $JAVA_HOME
#export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/bin/java
#export PATH=$PATH:/usr/lib/jvm/java-11-openjdk-amd64/bin
#export PATH=$PATH:/opt/bitnami/cassandra/bin
#echo $JAVA_HOME

echo "Starting ssh server"
sudo service ssh restart

echo "Ensuring grafana port is open"
/bin/bash -c "
        while ! nc -z grafana 3000;
        do
          echo 'waiting';
          sleep 1;
        done;
      "
	  
echo "Ensuring grafana datasource is registered"
curl 'http://admin:admin@grafana:3000/api/datasources' -X POST \
-H 'Content-Type: application/json;charset=UTF-8' \
--data-binary '{"name":"graphite","type":"graphite","url":"http://graphite:80",
"access":"proxy","isDefault":true,"basicAuth":true,"basicAuthUser":"guest","basicAuthPassword":"guest"}'

echo "######### </Running custom script> #########"
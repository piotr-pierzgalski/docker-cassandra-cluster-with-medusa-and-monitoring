echo "######### <Running custom script> #########"

echo "Starting ssh server"
sudo service ssh restart

echo "Starting node exporter"
sudo nohup /go/src/github.com/prometheus/node_exporter/node_exporter &

echo "######### </Running custom script> #########"
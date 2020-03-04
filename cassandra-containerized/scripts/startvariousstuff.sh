echo "######### <Running custom script> #########"

echo "Starting ssh server"
sudo service ssh start

echo "Starting node exporter"
sudo nohup ${GOPATH-$HOME/go}/src/github.com/prometheus/node_exporter/node_exporter &

echo "######### </Running custom script> #########"
exec /docker-entrypoint.sh "$@"
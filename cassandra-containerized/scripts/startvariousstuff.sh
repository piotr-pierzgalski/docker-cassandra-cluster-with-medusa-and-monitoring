echo "######### <Running custom script> #########"

echo "Starting ssh server"
sudo service ssh start

echo "######### </Running custom script> #########"
exec /docker-entrypoint.sh "$@"
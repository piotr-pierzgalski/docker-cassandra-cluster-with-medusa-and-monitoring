oldIFS=$IFS
IFS=','

for target in $1; do
  sed -i 's/<target_placeholder>/"'"$target"':7070",<target_placeholder>/' /etc/prometheus/tg_cassandra.json
  sed -i 's/<target_placeholder>/"'"$target"':9100",<target_placeholder>/' /etc/prometheus/tg_node.json
done

sed -i 's/,<target_placeholder>//' /etc/prometheus/tg_cassandra.json
sed -i 's/,<target_placeholder>//' /etc/prometheus/tg_node.json

IFS=oldIFS
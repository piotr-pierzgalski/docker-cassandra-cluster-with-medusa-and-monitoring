FROM prom/prometheus

ARG CassandraNodesToMonitor
ENV CassandraNodesToMonitor ${CassandraNodesToMonitor}

COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY tg_cassandra.json /etc/prometheus/tg_cassandra.json
COPY tg_node.json /etc/prometheus/tg_node.json

COPY endpointconstructorscript.sh /etc/prometheus/endpointconstructorscript.sh
RUN sh /etc/prometheus/endpointconstructorscript.sh ${CassandraNodesToMonitor}
RUN cat /etc/prometheus/tg_cassandra.json
RUN cat /etc/prometheus/tg_node.json
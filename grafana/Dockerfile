FROM grafana/grafana

COPY prometheus-datasource.yaml /etc/grafana/provisioning/datasources/prometheus-datasource.yaml
COPY dashboards.yaml /etc/grafana/provisioning/dashboards/dashboards.yaml
RUN mkdir -p /var/lib/grafana/dashboards
COPY dashboards/c-cluster-metrics.json /var/lib/grafana/dashboards
COPY dashboards/c-cluster-overview.json /var/lib/grafana/dashboards
COPY dashboards/c-table-metrics.json /var/lib/grafana/dashboards
COPY dashboards/system-metrics.json /var/lib/grafana/dashboards
#COPY dashboards /var/lib/grafana/dashboards
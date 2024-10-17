# otc.servicecatalogs.prometheus

## About

The following components deploy a Grafana, Prometheus server, node exporters, and alert managers on the VMs:
* Grafana automatically adds Prometheus server as its data source.
* Prometheus server automatically scrapes metrics from new node exporters, sends alerts to alert manager endpoints, as well as monitors Grafana and alertmanager endpoints.
* Security groups for TCP connections between components are auto-created.
* All connections between Grafana, Prometheus server, and node exporters are TLS protected with basic authentication (self-signed certificate and auto-generated password).

![Fig. Prometheus](../topology/prometheus/topology.png 'Prometheus')

## How to use

https://docs.otc.t-systems.com/cloud-create/umn/service_catalogs/prometheus.html

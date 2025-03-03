# Integration matrix


## Logs

### Kubernetes

See [library](https://charmhub.io/loki-k8s/libraries/loki_push_api) for the `loki_push_api` interface.

The following classes are available, depending on your use case.

#### Workloads with native support

Use `LokiPushApiConsumer`

#### Workloads without native support

* Starting with Juju 3.4.1, use the Pebble-native `LogForwarder`.  
* On earlier versions, use `LogProxyConsumer`. This method injects promtail into the workload and configure it to scrape logs. Not suitable for air-gapped environments.

### VMs and bare-metal

Use `COSAgentProvider` together with the `cos_agent` relation interface.

Interacts with the subordinate Grafana Agent charm and configures it to pull logs from `/var/log` as well as any slots the principal charm
configures using snap slots.

See [library](https://charmhub.io/grafana-agent/libraries/cos_agent) for details.

### Legacy LMA

Use [COS Proxy](https://charmhub.io/cos-proxy) to bridge the gap without having to change your charm code or interfaces.

Do note that this is not intended to be a permanent solution, rather a temporary stop-gap for users migrating. Over time, you should migrate to your preference of the options described above.

### Uncharmed workloads

Use the [Grafana agent snap](https://snapcraft.io/grafana-agent) and manually configure it to send logs to your COS deployment.

## Metrics

### Kubernetes

#### Workloads with metrics endpoints

Use `MetricsEndpointProvider` together with the `prometheus_scrape` relation interface.

Suitable when your charm either includes an exporter, or there is a native metrics endpoint
included in your workload. To be used together with a Grafana Agent that acts as the collector.

See [library](https://charmhub.io/prometheus-k8s/libraries/prometheus_scrape) for details.

#### Workloads with remote write

Use `PrometheusRemoteWriteConsumer` together with the `prometheus_remote_write` relation interface.

Suitable when your workload natively supports Prometheus remote write.

See [library](https://charmhub.io/prometheus-k8s/libraries/prometheus_remote_write) for details.

### VMs and bare-metal

Use `COSAgentProvider` together with the `cos_agent` relation interface to automatically
deploy and configure Grafana Agent to scrape and forward your metrics.

Includes node-level metrics by default. Allows configuration of additional endpoints
to scrape, catering to the custom exporter use case.

### Legacy LMA

Use [COS Proxy](https://charmhub.io/cos-proxy) to bridge the gap without having to change your charm code or interfaces.

Do note that this is not intended to be a permanent solution, rather a temporary stop-gap for users migrating. Over time, you should migrate to your preference of the options described above.


### Uncharmed workloads

This can be set up in two ways, either pushing data from your uncharmed workload into COS, or by having either your Prometheus or Grafana Agent scrape (pull) data from the workload. 

* For scraping, see the [Prometheus Scrape Target charm](https://charmhub.io/prometheus-scrape-target-k8s).
* For pushing, manually install and configure the [Grafana Agent snap](https://snapcraft.io/grafana-agent).

## Traces

### Kubernetes

Configures either your workload or your charm (or both) to send tracing telemetry to either a Grafana Agent or Tempo.  

#### Workload tracing

Use the `TracingEndpointRequirer` from the [`tracing` library](https://charmhub.io/tempo-coordinator-k8s/libraries/tracing).

#### Charm tracing

Use the `TracingEndpointRequirer` from the [`charm_tracing` library](https://charmhub.io/tempo-coordinator-k8s/libraries/charm_tracing).

### VMs and bare-metal

#### Workload tracing

Use the `COSAgentProvider` from the [`cos_agent` library](https://charmhub.io/grafana-agent/libraries/cos_agent) to receive available endpoints for shipping traces, and then configuring your workload to use them.

#### Charm tracing

Not available.

### Legacy LMA

Not available

### Uncharmed workloads

Use the [Grafana agent snap](https://snapcraft.io/grafana-agent) and manually configure your workload to send traces to it, and it to send traces to your COS deployment.

## Dashboards

### Kubernetes

### VMs and bare-metal

### Legacy LMA

### Uncharmed workloads

## Alert Rules

### Kubernetes

### VMs and bare-metal

### Legacy LMA

### Uncharmed workloads



|             | K8s charm                                                                                                                                               | Machine charm                                                                                  | Legacy charms - LMA deps         | Non-juju workload                          |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | -------------------------------- | ------------------------------------------ |
| [Logs](/t/cos-lite-docs-logging-architecture/13926)        |  | [cos_agent] (subordinate, pulls logs from `/var/log` or from other snaps with a matching slot) | [cos-proxy]                      | [grafana-agent snap] (manually configured) |
| Metrics     | [prometheus_scrape] (in-model), [prometheus_remote_write] (CMR) - with grafana-agent                                                                    | [cos_agent]                                                                                    | [cos-proxy]                      | [scrape-target], [grafana-agent snap]      |
| Traces      | [tracing] (instrumented workloads), [charm_tracing] (for the charm itself)                                                                                | [tracing] (CMR), [cos_agent]                                                                   | N/A                              | [grafana-agent charm]                      | 
| Dashboards  | [grafana_dashboard], [cos-configuration]                                                                                                                | [cos_agent], [cos-configuration]                                                               | [cos-proxy], [cos-configuration] | [cos-configuration]                        |
| Alert rules | via metrics and logs relations, [cos-configuration]                                                                                                     | [cos_agent], [cos-configuration]                                                               | [cos-proxy], [cos-configuration] | [cos-configuration]                        |

- The [COS Lite bundle](https://charmhub.io/cos-lite) does not include tracing by default; however, there's a bundle overlay for that.

[loki_push_api]: https://charmhub.io/loki-k8s/libraries/loki_push_api
[prometheus_scrape]: https://charmhub.io/prometheus-k8s/libraries/prometheus_scrape
[prometheus_remote_write]: https://charmhub.io/prometheus-k8s/libraries/prometheus_remote_write
[tracing]: https://charmhub.io/tempo-k8s/libraries/tracing
[charm_tracing]: https://charmhub.io/tempo-k8s/libraries/charm_tracing
[grafana_dashboard]: https://charmhub.io/grafana-k8s/libraries/grafana_dashboard
[cos-configuration]: https://charmhub.io/cos-configuration-k8s
[cos_agent]: https://charmhub.io/grafana-agent/libraries/cos_agent
[cos-proxy]: https://charmhub.io/cos-proxy
[grafana-agent snap]: https://snapcraft.io/grafana-agent
[grafana-agent charm]: https://charmhub.io/grafana-agent-k8s
[scrape-target]: https://charmhub.io/prometheus-scrape-target-k8s
 [LogProxyConsumer]: https://charmhub.io/loki-k8s/libraries/loki_push_api

## External links
- [Monitoring Agents Comparative Study](https://wiki.anuket.io/display/HOME/Monitoring+Agents+Comparative+Study)
- [How to integrate COS-Lite with non-juju workloads](/t/12005)
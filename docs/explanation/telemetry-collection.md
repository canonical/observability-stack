# Telemetry collection

To effectively _observe_ and monitor your systems, COS needs to **gather telemetry**. For each telemetry type, there are a few different “modes” of collecting data. Let’s explore each one in more detail!

## Metrics

Metrics can be gathered via a **pull** or **push** mechanism.

The standard practice is for a workload to expose its metrics so they can be scraped; this is a **pull** mechanism, because the _observer_ (Prometheus, OpenTelemetry Collector, Grafana Agent, etc.) fetches — _pulls_ — the metrics from the _observed workload_.

In practice, when you `juju relate` something to Prometheus (or OpenTelemetry Collector, or anything that supports the relation) over `prometheus_scrape`, it’s automatically configured to periodically pull metrics from the _observed workload_ and store them as time series. If you want to know more about the details, check out the [Prometheus documentation](https://prometheus.io/docs/introduction/overview/).

Sometimes, a _pull_ model is not desirable: network restrictions, metrics from short-lived jobs, and more factors can make this model ineffective. An alternative approach is the **push** mechanism, where the _observed workload_ sends — _pushes_ — the metrics to the _observer_.

A particularly relevant example is our recommended usage of OpenTelemetry Collector: instead of individually relating all the components in your system to COS, the Collector serves as your _aggregation point_. While the metrics from your system are _pulled_ by the Collector, they are sent to Prometheus via a _push_ mechanism: the [remote-write](https://prometheus.io/docs/specs/remote_write_spec_2_0/).

Again, relating two components — such as OpenTelemetry Collector and Prometheus — over `prometheus_remote_write` automatically configures the integration.

## Logs

Logs are usually saved to file or printed to `stdout`. They are gathered via a **push** mechanism.

Some workloads support pushing their logs directly to Loki; when that’s not possible, a charmed workload has two possible approaches: use something else to gather the log files (OpenTelemetry Collector, Grafana Agent), or use [Pebble log forwarding](https://charmhub.io/loki-k8s/docs/pebble-log-forwarding) to send the `stdout` logs.

In practice, when you `juju relate` something to Loki (or OpenTelemetry Collector) over `loki_push_api`, it’s automatically configured to send logs from the _observed workload_ as they are generated.

## Traces

Traces are typically generated in the observed system(s). They are sent from the system over a **push** mechanism and stitched together in the tracing backend to show the full flow of a specific action among multiple systems. Applications are often _instrumented_ using an instrumentation library to generate traces. Many workloads and frameworks already contain the tracing instrumentation.

There are several formats in which traces can be sent. Our collectors such as OpenTelemetry Collector or Grafana Agent receive traces in most major formats and send them further to [Charmed Tempo](https://discourse.charmhub.io/t/charmed-tempo-ha/15531). Charms are often responsible for passing the address of the tracing receiver to the workload configuration.
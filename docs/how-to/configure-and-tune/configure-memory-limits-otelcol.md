---
myst:
 html_meta:
   description: "Configure the memory consumption limit of the OpenTelemetry Collector to avoid out of memory scenarios."
---

# How to configure the memory limiting processor in the OpenTelemetry Collector

The `opentelemetry-collector` charm offers a --- CharmHub link --- config option to configure the soft limit for the [collector's memory limiter processor](https://github.com/open-telemetry/opentelemetry-collector/tree/main/processor/memorylimiterprocessor). This processor is applied to all of the collector's pipelines. The configuration allows the user to set a soft limit for the collector's memory usage as a percentage of the total memory available on the host. The hard limit is always set at 15% greater than the soft limit. In cases where the user inputs invalid requests, the charm defaults to 50% for the soft limit.

The processor will enter memory limited mode and will start refusing the data when memory usage exceeds the soft limit by returning errors to the preceding component in the pipeline that made the telemetry function call. This is a non-permanent error. When receivers see this error they are expected to retry sending the same data or
apply backpressure to their own data sources in order to slow the inflow of data into the Collector, and to allow memory usage to go below the set limits. When the memory usage is above the hard limit the processor will additionally force garbage collection to be performed.

```{warning}
Incoming data can consume additional memory in a Collector before the memory limiter processor is able to reject it. Be sure to consider this when setting your limits.
```

## Relevant metrics and dashboards

Once the queue has hit its capacity (`otelcol_exporter_queue_size` > `otelcol_exporter_queue_capacity`) it rejects data (`otelcol_exporter_enqueue_failed_logs`). Rejected telemetry can also be seen in other metrics like `otelcol_exporter_enqueue_failed_metrics`, `otelcol_exporter_enqueue_failed_traces`.

--- COS Otelcol dashboard ---

---
myst:
 html_meta:
   description: "Configure the memory limiter processor in the OpenTelemetry Collector to prevent out-of-memory scenarios."
---

# How to configure memory limits for the OpenTelemetry Collector

The `opentelemetry-collector` charm applies a [memory limiter processor](https://github.com/open-telemetry/opentelemetry-collector/tree/main/processor/memorylimiterprocessor) to every pipeline. This processor monitors the collector's Go heap usage and begins refusing data when memory consumption crosses configurable thresholds:

- **Soft limit** (80% of the hard limit) — the processor starts returning errors to upstream pipeline components so that receivers can back-pressure or retry.
- **Hard limit** — the processor additionally forces garbage collection.

The `memory_limit_percentage` Juju config option sets the hard limit as a percentage of total available memory. The soft limit is always 80% of that value. Invalid inputs are clamped to `[0, 100]`; a value of `0` disables the limiter.

| User input (%) | Hard limit (% of total) | Soft limit (% of hard) |
|-----------------|-------------------------|------------------------|
| -10             | 0 (disabled)            | 0                      |
| 50              | 50                      | 40                     |
| 100 *(default)* | 100                     | 80                     |

```{warning}
The memory limiter processor is **not** a replacement for properly sizing the host or container where the collector runs.
If the collector consistently operates near its memory limit, the correct response is to add resources or scale out — not to raise the limit further.
```

## Prerequisites

- A deployed `opentelemetry-collector` charm.
- Access to the collector's Prometheus metrics endpoint (port `8888` by default) or a Grafana dashboard that scrapes it.

## Identify when the collector is memory-limited

The memory limiter reports its activity through Prometheus metrics exposed on the collector's metrics endpoint.

### Check current Go heap usage

```shell
juju ssh <unit> "curl -s http://localhost:8888/metrics" | grep 'go_memstats_alloc_bytes{'
```

This returns the current Go heap allocation in bytes — the value the memory limiter monitors. Compare it to the configured limits:

```shell
juju ssh <unit> "cat /etc/otelcol/config.d/<unit_name>.yaml" | yq '.processors.memory_limiter'
```

### Check for refused telemetry

When the soft limit is exceeded the processor increments `otelcol_processor_refused_*` counters:

```shell
juju ssh <unit> "curl -s http://localhost:8888/metrics" | grep 'otelcol_processor_refused'
```

Key metrics to watch:

| Metric | Meaning |
|--------|---------|
| `otelcol_processor_refused_metric_points` | Metric data points refused by the memory limiter |
| `otelcol_processor_refused_log_records` | Log records refused |
| `otelcol_processor_refused_spans` | Trace spans refused |

Non-zero values confirm the collector is actively dropping telemetry due to memory pressure.

```{note}
`otelcol_exporter_send_failed_*` and `otelcol_receiver_refused_*` are **not** memory-limiter metrics. Those track exporter network errors and receiver-level rejections respectively.
```

### Check collector logs

The collector also logs when the limiter activates:

```shell
juju ssh <unit> "journalctl -u snap.opentelemetry-collector.opentelemetry-collector --since '10 min ago'" | grep -i "memory"
```

Look for messages such as `Memory usage is above soft limit. Refusing data.` or `Memory usage is above hard limit. Forcing a GC.`

## Configure the memory limit

Set the hard limit as a percentage of total available memory:

```shell
juju config <app> memory_limit_percentage=50
```

This sets the hard limit to 50% of total memory and the soft limit to 40% (80% of 50%).

To restore the default (hard limit at 100% of total memory):

```shell
juju config <app> memory_limit_percentage=100
```

To disable the memory limiter entirely:

```shell
juju config <app> memory_limit_percentage=0
```

### Verify the new configuration

After changing the config, confirm the updated limits:

```shell
juju ssh <unit> "cat /etc/otelcol/config.d/<unit_name>.yaml" | yq '.processors.memory_limiter'
```

Expected output for `memory_limit_percentage=50` on a host with 500 MiB total memory:

```yaml
check_interval: 1s
limit_mib: 250
spike_limit_mib: 50
```

Where `limit_mib` is the hard limit and the soft limit is `limit_mib - spike_limit_mib`.

## How total memory is determined

The charm reads the cgroup memory limit from `/sys/fs/cgroup/memory.max`. If the file is absent or contains `max` (no cgroup limit), the total physical memory of the machine is used instead.

```shell
juju ssh <unit> "cat /sys/fs/cgroup/memory.max"
```

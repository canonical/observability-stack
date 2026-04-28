---
myst:
 html_meta:
   description: "Configure the memory limiter processor in the OpenTelemetry Collector to prevent out-of-memory scenarios."
---

# How to configure memory limits for the OpenTelemetry Collector

The `opentelemetry-collector` charm applies a [memory limiter processor](https://github.com/open-telemetry/opentelemetry-collector/tree/main/processor/memorylimiterprocessor) to every pipeline. This processor monitors the collector's Go heap usage and begins refusing data when memory consumption crosses configurable thresholds:

- **Soft limit** (80% of the hard limit): the processor starts refusing data so that receivers propagate backpressure to their data sources.
- **Hard limit**: the processor additionally forces garbage collection.

The `memory_limit_percentage` Juju config option sets the hard limit as a percentage of total available memory. The soft limit is always 80% of that value. A value of `0` disables the limiter.

| User input (%)  | Hard limit (% of total) | Soft limit (% of total) |
|-----------------|-------------------------|-------------------------|
| 0               | 0 (disabled)            | 0                       |
| 50              | 50                      | 40                      |
| 100 *(default)* | 100                     | 80                      |

Values outside `[0, 100]` or non-integer strings are rejected: the charm enters BlockedStatus and the Opentelemetry Collector workload process continues operations with the fallback value of 100%.

```{warning}
The memory limiter processor is **not** a replacement for properly sizing the host or container where the collector runs.
If the collector consistently operates near its memory limit, the correct response is to add resources or scale out; not to raise the limit further.
```

## Identify when the collector is memory-limited

The memory limiter reports its activity through logs and metrics.

### Check current Go heap usage

```shell
juju ssh <unit> "curl -s http://localhost:8888/metrics" | grep 'go_memstats_alloc_bytes{'
```

This returns the current Go heap allocation in bytes; the same value the memory limiter monitors (`runtime.MemStats.Alloc`). Compare it to the configured limits:

```shell
juju ssh <unit> "cat /etc/otelcol/config.d/<unit_name>.yaml" | yq '.processors.memory_limiter'
```

```{note}
The memory limiter checks heap usage every second, but Prometheus scrapes `go_memstats_alloc_bytes` much less frequently (typically every minute). Go heap can spike between scrapes, trigger the limiter, and be garbage-collected before the next scrape. A low `go_memstats_alloc_bytes` value does not mean the limiter has not been triggered; check the `otelcol_processor_refused_*` counters and collector logs instead.
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

The collector logs when the limiter activates. Filter for memory-related messages:

```shell
juju ssh <unit> "tail -f /var/snap/opentelemetry-collector/common/otelcol.log" | grep -i "memory usage"
```

Messages to look for, in order of escalation:

1. Soft limit reached; the processor starts refusing incoming data:

   ```text
   warn  memorylimiter  Memory usage is above soft limit. Refusing data.  {"cur_mem_mib": 8}
   ```

2. Hard limit reached; the processor forces garbage collection:

   ```text
   warn  memorylimiter  Memory usage is above hard limit. Forcing a GC.  {"cur_mem_mib": 12}
   ```

3. Post-GC report; heap usage after garbage collection:

   ```text
   info  memorylimiter  Memory usage after GC.  {"cur_mem_mib": 11}
   ```

4. Upstream receivers refuse telemetry and propagate backpressure to their data sources:

   ```text
   error  adapter/receiver.go  ConsumeLogs() failed  {"error": "data refused due to high memory usage"}
   ```

## Configure the memory limit

Set the hard limit as a percentage of total available memory:

```shell
juju config <app> memory_limit_percentage=50
```

This sets the hard limit to 50% of total memory and the soft limit to 40% (80% of 50%).

To restore the default (hard limit at 100% of total memory):

```shell
juju config <app> --reset memory_limit_percentage
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

Explanation: 500 MiB × 50% = 250 `limit_mib`; 250 × 20% = 50 `spike_limit_mib`. The soft limit is `limit_mib - spike_limit_mib` (i.e. 200 MiB).

## How total memory is determined

The charm reads the cgroup memory limit from `/sys/fs/cgroup/memory.max`. If the file is absent or contains `max` (no cgroup limit), the total physical memory of the machine is used instead.

```shell
juju ssh <unit> "cat /sys/fs/cgroup/memory.max"
```

## Override the default memory limiter

If you require more control over the configuration of the `memory_limiter`, the charm's `processors` config option allows you to define custom processors, applied to all pipelines in YAML format. For example, define an `override.yaml` to change the `check_interval` to 10 seconds:

```yaml
memory_limiter:
  check_interval: 10s
  limit_mib: 250
  spike_limit_mib: 50
```

and apply it with:

```shell
juju config <app> processors=@override.yaml
```

```{note}
If you define a custom `memory_limiter` processor, the default one will be replaced. Make sure to configure it with appropriate limits to avoid OOM kills.
```

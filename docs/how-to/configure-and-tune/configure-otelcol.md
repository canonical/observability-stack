---
myst:
  html_meta:
    description: "Configure the OpenTelemetry Collector to avoid dropped telemetry."
---

# How to configure OpenTelemetry Collector for production

The exporter queue and the batch processor control how the charmed OpenTelemetry Collector (otelcol) buffers telemetry before sending it to a backend. Poorly chosen values can cause delayed delivery, rejected samples, or silent data loss. This guide describes the values to avoid and how to tune them.

## Keep the exporter queue size at or above the default

Keep the exporter queue size (the `queue_size` option of `sending_queue`) at or above the default value of 1000.

A smaller queue fills up faster during a backend slowdown or outage, which results in `sending queue is full` errors and dropped telemetry. See [`sending queue is full`](../validate-and-troubleshoot/troubleshooting.md#sending-queue-is-full) for diagnosis steps.

```yaml
exporters:
  loki/send-loki-logs/0:
    sending_queue:
      enabled: true
      queue_size: 1000
```

## Avoid drastic changes in queues in tiered collectors

In a [tiered OpenTelemetry Collector topology](../integrate/tiered-otelcols.md), don't drastically lower the queue size (for example, down to 100) in downstream collectors.
A small queue in a downstream collector backs up and propagates the backpressure along the entire chain.

## Avoid over-chaining otelcols

Each collector layer has its own queue, and chaining queues accumulates latency. Data buffered across several queues can exceed the time window that the backend accepts for sample timestamps. When it's finally delivered, the backend rejects it with a "timestamp too old" error.

For details on the resulting backend errors, see [`err-mimir-sample-out-of-order` and `err-mimir-sample-timestamp-too-old`](../validate-and-troubleshoot/troubleshooting.md).

## Keep the batch size low for heterogeneous metric sources

When you configure large batch sizes (thousands of items), a single malformed or unparseable metric name can cause the backend to reject the entire batch. Examples include names with non-ASCII characters, such as the microsecond symbol `µs`. For example, Mimir rejects metrics with non-ASCII characters.

This leads to silent data loss: every record in the batch is dropped on each export attempt.

When you ingest metrics from heterogeneous sources, either disable the batch processor or keep its batch size low. Where possible, also sanitize metric names at the source. See [`dropping items`](../validate-and-troubleshoot/troubleshooting.md#dropping-items) for diagnosis steps.

## Related topics

- [How to tier OpenTelemetry Collector with different pipelines per data stream](../integrate/tiered-otelcols.md)
- [How to configure memory limits for the OpenTelemetry Collector](configure-memory-limits-otelcol.md)
- [Troubleshooting](../validate-and-troubleshoot/troubleshooting.md)

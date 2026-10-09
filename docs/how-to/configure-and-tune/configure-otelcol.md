
## Queue size
Maintain exporter queue size (the `queue_size` config option) no less than the default value (1000).

## Tiered otelcols
Chaining queues across multiple collector layers accumulates latency, so buffered data held across
chained queues risks exceeding timestamp validity windows, triggering "timestamp too old" errors
upon eventual delivery.

In tiered otelcols setups, avoid lowering queue sizes drastically (e.g., down to 100) in downstream otelcols,
to avoid queues from backing up along the entire critical chain.

See the [../validate-and-troubleshoot/troubleshootin.md](troubleshooting guide) for more details.

## Batch size
When large batch sizes (thousands of items) are configured, a single malformed or unparseable metric name
inside the batch (e.g. non-ascii microsecond symbols `µs` or utf8 characters) may cause downstream backends
to reject the entire batch. For example, Mimir is configure to reject metrics with non-ascii characters.
This would lead to silent data loss, dropping the entire batch size of records per export attempt.

Disable or keep batch processing size low when ingesting metrics from heterogeneous sources.


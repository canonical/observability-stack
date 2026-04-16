---
myst:
 html_meta:
  description: "Size your COS or COS Lite deployment: minimum hardware, per-workload resource tables, storage estimation, and resource formulas."
---

# Sizing guide

Use this page to determine the hardware you need **before** deploying COS or
COS Lite in production.
If you don't yet know how much telemetry your workloads generate, start with
[How to evaluate telemetry volume](../how-to/configure-and-tune/evaluate-telemetry-volume).

## COS

3 nodes of 8 vCPU / 16 GB RAM or better, plus dedicated storage nodes.
At least 100 GB disk space per node.

## COS Lite

As a general rule, plan for a single VM with at least 4 vCPU / 8 GB RAM.

If you have an [estimate for the expected telemetry rate](../how-to/configure-and-tune/evaluate-telemetry-volume), refer to the tables below.

### Metrics (Prometheus)

| Metrics/min | vCPUs | Mem (GB) | Disk (GiB/day) |
|-------------|-------|----------|----------------|
|     1 M     |   2   |     6    |        6       |
|     3 M     |   3   |     9    |       14       |
|     6 M     |   3   |    14    |       27       |

### Logs (Loki)

| Logs/min | vCPUs | Mem (GB) | Disk (GiB/day) |
|----------|-------|----------|----------------|
|   60 k   |   5   |     8    |       20       |
|   180 k  |   5   |     8    |       60       |
|   360 k  |   6   |     8    |       120      |

### Combined workload

The tables above show metrics-only and logs-only resource needs.
When you run both Prometheus and Loki on the same node, use the formulas
below to estimate the combined resource requirements.

```{note}
These formulas are local approximations based on load testing a COS Lite deployment on an
8 vCPU / 16 GB SSD VM running MicroK8s, with 20 concurrent dashboard
viewers. Apply a margin of at least 10 % for production use.
```

**Idle baseline** (COS Lite with no ingestion): ~0.5 vCPU, ~2.6 GB RAM.

**Maximum tested ingestion rates:**

- 6.6 M metric data points/min (metrics only)
- 6 M metric data points + 3,600 log lines/min
- 4.5 M metric data points + 320 k log lines/min

**Resource formulas** — where $L$ = log lines/min and $M$ = metric data points/min:

$$
\text{disk (GiB/day)} = 3.011 \times 10^{-4}\,L + 3.823 \times 10^{-6}\,M + 1.023
$$

$$
\text{vCPUs} = 1.89 \arctan(1.365 \times 10^{-4}\,L) + 1.059 \times 10^{-7}\,M + 1.644
$$

$$
\text{mem (GB)} = 2.063 \arctan(2.539 \times 10^{-3}\,L) + 1.464 \times 10^{-6}\,M + 3.3
$$

### Storage estimation

A deployment that handles roughly 1 M metrics/min from 150 targets and
100 k log lines/min from 150 targets has a storage growth rate of about
**50 GiB per day** under normal operations.

To estimate total storage, multiply the daily growth rate by the desired
retention period. For example, a two-month retention window requires
approximately **3 TiB** of storage for telemetry alone.

For guidance on choosing a storage backend for production, see
[Storage best practices](storage).
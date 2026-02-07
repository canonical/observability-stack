# System requirements

## COS
3 nodes of 8cpu16gb or better. At least 100 GB disk space.


## COS Lite
As a general rule, plan for a 4cpu8gb or better VM.

If you have an [estimate for the expected telemetry rate](../how-to/evaluate-telemetry-volume.md), refer to the tables below.


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
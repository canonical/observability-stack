# COS vs. COS Lite

|                             | COS                                 | COS Lite                                                                                        |
| --------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------- |
| Purpose                     | Horizontally scalable, enterprise-ready             | Resource-constrained or near-edge deployment                                                                 |
| Telemetry types             | Logs, metrics, traces               | Logs, metrics                                                                                   |
| Resiliency                  | HA; S3 storage (managed separately) | Single node - only storage, if set up correctly; multi node - non-identical replication, not HA |
| Minimum system requirements | 1x 8cpu16gb + storage nodes         | 1x 4cpu8gb (+storage nodes, if any)                                                             |

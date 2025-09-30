# Release policy

Our release policy includes two kinds of releases, short-term releases and long-term support (LTS) releases.

We release every six months, same as Ubuntu, and our LTS releases coincide with Ubuntu.

## Short-term releases
Short-term releases are supported for nine months by providing security patches and critical bug fixes.

| Track   | Release date        | End of life         | Ubuntu base | Min. Juju version | Brief summary                                                                                     |
|---------|---------------------|---------------------|-------------|-------------------|---------------------------------------------------------------------------------------------------|
| `2`     | 2025-10 (predicted) | 2026-07 (predicted) | 24.04       | 3.6               |  Mimir 2.x, Prometheus 2.x, Loki 2.x (COS Lite), Loki 3.0 (COS), Grafana 12.x, opentelemetry-collector 0.x |
| `1`     | 2025-05             | 2026-02             | 24.04       | 3.1               | Mimir 2.x, Prometheus 2.x, Loki 2.x (COS Lite), Loki 3.0 (COS), Grafana 9.x, Grafana Agent 0.40.4 |



## Long-term support


| Track   | Release date        | End of life         | Ubuntu base | Min. Juju version | Brief summary                                                                                     |
|---------|---------------------|---------------------|-------------|-------------------|---------------------------------------------------------------------------------------------------|
| `3-lts` | 2026-04 (predicted) | 2038-04 (predicted) | 26.04       |                   |                                                                                                   |

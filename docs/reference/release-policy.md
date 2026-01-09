# Release policy

Our release policy includes two kinds of releases, short-term releases and long-term support (LTS) releases.

We release every six months, same as Ubuntu, and our LTS releases coincide with [Ubuntu's LTS release cadence](https://ubuntu.com/about/release-cycle).

## Short-term releases
Short-term releases are supported for nine months by providing security patches and critical bug fixes.

| Track | Release date | End of life | Ubuntu base                          | Min. Juju version | Brief summary                                                                                             |
| ----- | ------------ | ----------- | ------------------------------------ | ----------------- | --------------------------------------------------------------------------------------------------------- |
| `2`   | 2025-11      | 2026-07     | 24.04 (rocks), 22.04+ (subordinates) | 3.6               | Mimir 2.x, Prometheus 2.x, Loki 2.x (COS Lite), Loki 3.0 (COS), Grafana 12.x, opentelemetry-collector 0.x |
| `1`   | 2025-05      | 2026-02     | 24.04 (rocks)                        | 3.1               | Mimir 2.x, Prometheus 2.x, Loki 2.x (COS Lite), Loki 3.0 (COS), Grafana 9.x, Grafana Agent 0.40.4         |


## Long-term support

| Track   | Release date        | End of life         | Ubuntu base                          | Min. Juju version | Brief summary |
| ------- | ------------------- | ------------------- | ------------------------------------ | ----------------- | ------------- |
| `3-lts` | 2026-04 (predicted) | 2038-04 (predicted) | 26.04 (rocks), 22.04+ (subordinates) |                   |               |


## Charmhub tracks and git branches
We create the Charmhub track at beginning of a cycle, and a git branch at end of cycle.
For example, during June-September 2025, we had track `2` on Charmhub, but only `track/1` and `main` branches on github.

---
myst:
  html_meta:
    description: "Manually enable Tempo HA tracing receiver protocols for uncharmed workloads."
---

# How to manually enable a Tempo HA tracing receiver

Tempo HA usually enables receiver endpoints only for protocols requested by active
`tracing` relations. If needed, you can still enable a receiver manually and send
traces from workloads that are not related to the coordinator charm.

This is useful for uncharmed workloads that can emit traces in one of Tempo HA's
[supported protocols](https://discourse.charmhub.io/t/tempo-k8s-docs-tracing-protocols-reference/14010).

## Prerequisites

This guide assumes Tempo HA is already deployed with COS Lite. If needed, first
follow [How to add tracing to COS Lite](add-tracing-to-cos-lite.md).

## Manually enable a protocol receiver

The `tempo-coordinator-k8s` charm exposes configuration options named
`always_enable_<PROTOCOL>`. Set the relevant option to `true` to enable a
protocol even when no Juju integration is requesting it.

For example, to enable `jaeger-thrift-http`:

```bash
juju config tempo-coordinator-k8s always_enable_jaeger_thrift_http=true
```

## Retrieve the receiver endpoint

After enabling the protocol, list the active receivers:

```bash
juju run tempo-coordinator-k8s/0 list-receivers
```

Example output:

```text
Running operation 5 with 1 task
  - task 6 on unit-tempo-coordinator-k8s-0

Waiting for task 6...
jaeger-grpc: 10.211.88.9:14250
jaeger-thrift-http: http://10.211.88.9:14268
otlp-grpc: 10.211.88.9:4317
otlp-http: http://10.211.88.9:4318
```

In this example, traces encoded with `jaeger-thrift-http` can be sent to
`http://10.211.88.9:14268`.

```{note}
Some workloads require an endpoint path suffix, such as `/api/traces` for
`jaeger-thrift-http`. Check your workload documentation for the exact URL.
```

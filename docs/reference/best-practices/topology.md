# Deployment Topology Best Practices

## Deploy in isolation
COS (or COS Lite) should be deployed in its own Juju model, and preferably on a separate substrate with a dedicated Juju controller.
"Grafana Agent<br/>(or OpenTelemetry Collector)"
```{mermaid}
flowchart LR

subgraph Infra A
A[Your workloads] -->|telemetry| collector["Otel Collector<br/>(or Grafana Agent)"]
end

subgraph Infra B
B["COS<br/>(or COS Lite)"]
end

subgraph Infra C
C[COS Alerter]
end

collector -->|telemetry| B
B -->|heartbeat| C
```

[COS Alerter](https://github.com/canonical/cos-alerter) should be deployed to let operators know whenever the routing of notifications from COS Lite stops working,
preventing a false sense of security. We advise to deploy COS Alerter on dedicated infra, separate from the COS Lite infra.

These precautions help to limit the blast radius in case of outages in the workloads you observe, or the observability stack itself.

## COS

Start with three units for each of the following:
- Loki backend
- Loki read
- Loki write
- Mimir backend
- Mimir read
- Mimir write
- Tempo compactor
- Tempo distributor
- Tempo ingester
- Tempo metrics generator
- Tempo querier
- Tempo query frontend

Set pod anti-affinity to hostname.


## COS Lite - scaled
Scale all COS Lite applications to three units, with pod anti-affinity set to hostname.
A storage unit may be co-located on each node. 

Note that in scaled COS Lite,
- Telemetry may slightly differ across units.
- Each unit would be a separate datasource in Grafana.

```{mermaid}
graph LR

subgraph Cluster

subgraph node-2
  prometheus/2
  loki/2
  alertmanager/2
  grafana/2
  db2[(Storage)]
end

subgraph node-1
  prometheus/1
  loki/1
  alertmanager/1
  grafana/1
  db1[(Storage)]
end

subgraph node-0
  prometheus/0
  loki/0
  alertmanager/0
  grafana/0
  db0[(Storage)]
end

end
```

For example, refer to the following overlay:

```yaml
applications:
  alertmanager:
    scale: 3
    constraints: tags=anti-pod.app.kubernetes.io/name=alertmanager,anti-pod.topology-key=kubernetes.io/hostname
  prometheus:
    scale: 3
    constraints: tags=anti-pod.app.kubernetes.io/name=prometheus,anti-pod.topology-key=kubernetes.io/hostname
  grafana:
    scale: 3
    constraints: tags=anti-pod.app.kubernetes.io/name=grafana,anti-pod.topology-key=kubernetes.io/hostname
  loki:
    scale: 3
    constraints: tags=anti-pod.app.kubernetes.io/name=loki,anti-pod.topology-key=kubernetes.io/hostname
```


## COS Lite - single node
This is the most light-weight deployment, which requires a minimum of 4cpu8gb node to run.

```{mermaid}
graph LR
subgraph "4cpu-8gb or better"
  prometheus/0
  loki/0
  alertmanager/0
  grafana/0
end
```

## References
- High availability: [Canonical K8s](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/explanation/high-availability/),
  [MicroK8s](https://microk8s.io/docs/high-availability).


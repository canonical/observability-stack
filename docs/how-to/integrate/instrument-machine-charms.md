---
myst:
 html_meta:
  description: "Learn to intrument machine charms with Canonical Observability Stack on Kubernetes using the Opentelemetry Collector subordinate charm for metrics, logs, and dashboards."
---

# Instrumenting machine charms

## Prerequisites

- A charmed application that is running in a virtual, or physical, machine.
- The Canonical Observability Stack, running on Kubernetes.

## Introduction

This tutorial will teach you how to integrate a charm deployed on a machine substrate with the Canonical Observability Stack running on Kubernetes.

The Opentelemetry Collector machine charm handles installation, configuration, and Day 2 operations specific to the [Opentelemetry Collector](https://opentelemetry.io/docs/collector/), using [Juju](https://canonical.com/juju). The charm is designed to run in virtual machines as a [subordinate](https://discourse.charmhub.io/t/subordinate-applications/1053).

```{note}
Application units are typically run in an isolated container on a machine with no knowledge or access to other applications deployed onto the same machine.
When you relate a subordinate charm to a principal one, the subordinate will be deployed on the same machine on which the principal is running.
Subordinate units scale together with their principal.
```

## Ensure COS Lite is up and running

Before we get started, we will make sure that the Observability Stack is up and running in our `cos` model (follow the tutorial on [getting started with COS Lite](/tutorial/cos-lite-microk8s-sandbox)) in a Kubernetes controller, like this:

```text
$ juju status --relations

Model     Controller  Cloud/Region  Version  SLA          Timestamp
cos-lite  ck8s        k8s           3.6.19   unsupported  18:07:14-03:00

App           Version  Status  Scale  Charm             Channel        Rev  Address         Exposed  Message
alertmanager  0.28.0   active      1  alertmanager-k8s  2/stable       191  10.152.183.36   no
catalogue              active      1  catalogue-k8s     2/stable       113  10.152.183.195  no
grafana       12.0.2   active      1  grafana-k8s       2/stable       180  10.152.183.90   no
loki          2.9.15   active      1  loki-k8s          2/stable       217  10.152.183.57   no
prometheus    2.53.3   active      1  prometheus-k8s    2/stable       287  10.152.183.172  no
traefik       2.11.0   active      1  traefik-k8s       latest/stable  281  10.152.183.221  no       Serving at http://192.168.1.200

Unit             Workload  Agent  Address     Ports  Message
alertmanager/0*  active    idle   10.1.0.87
catalogue/0*     active    idle   10.1.0.33
grafana/0*       active    idle   10.1.0.214
loki/0*          active    idle   10.1.0.178
prometheus/0*    active    idle   10.1.0.90
traefik/0*       active    idle   10.1.0.35          Serving at http://192.168.1.200

Offer                            Application   Charm             Rev  Connected  Endpoint              Interface                Role
alertmanager-karma-dashboard     alertmanager  alertmanager-k8s  191  0/0        karma-dashboard       karma_dashboard          provider
grafana-dashboards               grafana       grafana-k8s       180  2/2        grafana-dashboard     grafana_dashboard        requirer
loki-logging                     loki          loki-k8s          217  2/2        logging               loki_push_api            provider
prometheus-metrics-endpoint      prometheus    prometheus-k8s    287  0/0        metrics-endpoint      prometheus_scrape        requirer
prometheus-receive-remote-write  prometheus    prometheus-k8s    287  2/2        receive-remote-write  prometheus_remote_write  provider

Integration provider                Requirer                     Interface              Type     Message
alertmanager:alerting               loki:alertmanager            alertmanager_dispatch  regular
alertmanager:alerting               prometheus:alertmanager      alertmanager_dispatch  regular
alertmanager:grafana-dashboard      grafana:grafana-dashboard    grafana_dashboard      regular
alertmanager:grafana-source         grafana:grafana-source       grafana_datasource     regular
alertmanager:replicas               alertmanager:replicas        alertmanager_replica   peer
alertmanager:self-metrics-endpoint  prometheus:metrics-endpoint  prometheus_scrape      regular
catalogue:catalogue                 alertmanager:catalogue       catalogue              regular
catalogue:catalogue                 grafana:catalogue            catalogue              regular
catalogue:catalogue                 prometheus:catalogue         catalogue              regular
catalogue:replicas                  catalogue:replicas           catalogue_replica      peer
grafana:grafana                     grafana:grafana              grafana_peers          peer
grafana:metrics-endpoint            prometheus:metrics-endpoint  prometheus_scrape      regular
grafana:replicas                    grafana:replicas             grafana_replicas       peer
loki:grafana-dashboard              grafana:grafana-dashboard    grafana_dashboard      regular
loki:grafana-source                 grafana:grafana-source       grafana_datasource     regular
loki:metrics-endpoint               prometheus:metrics-endpoint  prometheus_scrape      regular
loki:replicas                       loki:replicas                loki_replica           peer
prometheus:grafana-dashboard        grafana:grafana-dashboard    grafana_dashboard      regular
prometheus:grafana-source           grafana:grafana-source       grafana_datasource     regular
prometheus:prometheus-peers         prometheus:prometheus-peers  prometheus_peers       peer
traefik:ingress                     alertmanager:ingress         ingress                regular
traefik:ingress                     catalogue:ingress            ingress                regular
traefik:ingress-per-unit            loki:ingress                 ingress_per_unit       regular
traefik:ingress-per-unit            prometheus:ingress           ingress_per_unit       regular
traefik:metrics-endpoint            prometheus:metrics-endpoint  prometheus_scrape      regular
traefik:peers                       traefik:peers                traefik_peers          peer
traefik:traefik-route               grafana:ingress              traefik_route          regular
```

## Add the required integrations to our charm

In this example we use COS Lite to observe [Zookeeper](https://github.com/canonical/zookeeper-operator).

In order for it to be able to integrate with COS Lite, we will have to make some changes to the charm.

### Obtain the `cos_agent` library

Execute the following command to have Charmcraft fetch the required library from Charmhub.

```shell
charmcraft fetch-lib charms.grafana_agent.v0.cos_agent
```

### Add the needed `provider`

In the `metadata.yaml` of the zookeeper charm, we will now add the
`cos-agent` relation to the `provides` section.

```diff
[...]
provides:
  zookeeper:
    interface: zookeeper
+  cos-agent:
+    interface: cos_agent
+    limit: 1
[...]
```

### Integrate the library in our charm code

In `src/charm.py`, import the library.

```python
from charms.grafana_agent.v0.cos_agent import COSAgentProvider
```

Instantiate the `COSAgentProvider` object in the charm's `__init__` method.

```python
        # ...
        self._grafana_agent = COSAgentProvider(
            self,
            metrics_endpoints=[
                {"path": "/metrics", "port": NODE_EXPORTER_PORT},
                {"path": "/metrics", "port": JMX_PORT},
                {"path": "/metrics", "port": METRICS_PROVIDER_PORT},
            ],
            metrics_rules_dir="./src/alert_rules/prometheus",
            logs_rules_dir="./src/alert_rules/loki",
            dashboard_dirs=["./src/grafana_dashboards"],
            log_slots=["charmed-zookeeper:logs"],
        )
        # ...
```

As part of this constructor call, you may change the paths where metrics alert rules, log alert rules, and Grafana dashboard files are stored.

```{note}
To learn how to craft alert rules and dashboards, check [these examples](https://github.com/canonical/cos-configuration-k8s-operator/tree/main/tests/samples).
```

### Pack the charm:

We will now pack the charm using Charmcraft.

```shell
$ charmcraft pack
```

## Refreshing the Zookeeper charm

Switch to the machine model and refresh the
Zookeeper charm with the charm file we just created.

```
  juju switch lxd:admin/zoo # or wherever your zookeeper charm is deployed
  juju refresh zookeeper --path ./*.charm
```

Juju will now do an in-place upgrade of the charm, adding the `cos-agent` relation we just created. Verify that it's `active/idle` before proceeding.

```
$ juju status zoo

Model  Controller  Cloud/Region         Version  SLA          Timestamp
zoo    lxd         localhost/localhost  3.6.19   unsupported  18:24:39-03:00

App        Version  Status  Scale  Charm      Channel   Rev  Exposed  Message
zookeeper  3.9.2    active      1  zookeeper  3/stable  163  no

Unit          Workload  Agent  Machine  Public address  Ports  Message
zookeeper/0*  active    idle   1        10.72.158.122

Machine  State    Address        Inst id        Base          AZ            Message
1        started  10.72.158.122  juju-50c528-1  ubuntu@22.04  charm-dev-36  Running
```

## Deploy the Opentelemetry Collector machine charm

Now deploy the Opentelemetry Collector machine charm.

```
$ juju deploy opentelemetry-collector otelcol --channel 2/stable --base=ubuntu@22.04
$ juju status

Model  Controller  Cloud/Region         Version  SLA          Timestamp
zoo    lxd         localhost/localhost  3.6.19   unsupported  18:25:34-03:00

App        Version  Status   Scale  Charm                    Channel   Rev  Exposed  Message
otelcol             unknown      0  opentelemetry-collector  2/stable  248  no
zookeeper  3.9.2    active       1  zookeeper                3/stable  163  no

Unit          Workload  Agent  Machine  Public address  Ports  Message
zookeeper/0*  active    idle   1        10.72.158.122

Machine  State    Address        Inst id        Base          AZ            Message
1        started  10.72.158.122  juju-50c528-1  ubuntu@22.04  charm-dev-36  Running
```

At this point we have one `zookeeper` unit in `active` state, and a `opentelemetry-collector` in unknown state, with no units. This is, as mentioned earlier, because `opentelemetry-collector` is a [subordinate charm](https://discourse.charmhub.io/t/subordinate-applications/1053).

## Integrate the charms

Now integrate `zookeeper` with `opentelemetry-collector` over the `cos-agent` relation.

```
$ juju integrate zookeeper otelcol:cos-agent
```

Once the relation has been established, `otelcol` will be deployed together with the `zookeeper` unit, in the same machine. The status of the model at that point will be:

```
$ juju status

Model  Controller  Cloud/Region         Version  SLA          Timestamp
zoo    lxd         localhost/localhost  3.6.19   unsupported  18:28:50-03:00

App        Version  Status   Scale  Charm                    Channel   Rev  Exposed  Message
otelcol    0.130.0  blocked      1  opentelemetry-collector  2/stable  248  no       ['cloud-config']|['grafana-dashboards-provider']|['send-loki-logs']|['send-remote-write'] for cos-agent
zookeeper  3.9.2    active       1  zookeeper                3/stable  163  no

Unit          Workload  Agent  Machine  Public address  Ports  Message
zookeeper/0*  active    idle   1        10.72.158.122
  otelcol/1*  blocked   idle            10.72.158.122          ['cloud-config']|['grafana-dashboards-provider']|['send-loki-logs']|['send-remote-write'] for cos-agent

Machine  State    Address        Inst id        Base          AZ            Message
1        started  10.72.158.122  juju-50c528-1  ubuntu@22.04  charm-dev-36  Running
```

Note that despite `otelcol` being deployed and collecting telemetry, it is yet to forward them anywhere due to the lack of relations to the corresponding components in the observability stack.

## Relate Opentelemetry Collector to COS Lite

As the next step, we will relate Opentelemetry Collector to the COS Lite components. Specifically, to

* Prometheus for the metrics,
* Loki for the logs, and
* Grafana for the dashboards.

From the model our application is running, we can verify the [`offers`](https://documentation.ubuntu.com/juju/3.6/howto/manage-relations/#manage-relations) COS Lite is exposing:

```shell
$ juju find-offers -m ck8s:admin/cos-lite
Store  URL                                             Access  Interfaces
ck8s   admin/cos-lite.prometheus-metrics-endpoint      admin   prometheus_scrape:metrics-endpoint
ck8s   admin/cos-lite.prometheus-receive-remote-write  admin   prometheus_remote_write:receive-remote-write
ck8s   admin/cos-lite.alertmanager-karma-dashboard     admin   karma_dashboard:karma-dashboard
ck8s   admin/cos-lite.grafana-dashboards               admin   grafana_dashboard:grafana-dashboard
ck8s   admin/cos-lite.loki-logging                     admin   loki_push_api:logging
```

To be able to use them, we now need to consume them.


```shell
$ juju consume ck8s:admin/cos-lite.prometheus-receive-remote-write
$ juju consume ck8s:admin/cos-lite.loki-logging
$ juju consume ck8s:admin/cos-lite.grafana-dashboards
```

Once these commands have been executed, the status of our model will change slightly.

```
$ juju status
Model  Controller  Cloud/Region         Version  SLA          Timestamp
zoo    lxd         localhost/localhost  3.6.19   unsupported  18:31:41-03:00

SAAS                             Status  Store  URL
grafana-dashboards               active  ck8s   admin/cos-lite.grafana-dashboards
loki-logging                     active  ck8s   admin/cos-lite.loki-logging
prometheus-receive-remote-write  active  ck8s   admin/cos-lite.prometheus-receive-remote-write

App        Version  Status   Scale  Charm                    Channel   Rev  Exposed  Message
otelcol    0.130.0  blocked      1  opentelemetry-collector  2/stable  248  no       ['cloud-config']|['grafana-dashboards-provider']|['send-loki-logs']|['send-remote-write'] for cos-agent
zookeeper  3.9.2    active       1  zookeeper                3/stable  163  no

Unit          Workload  Agent  Machine  Public address  Ports  Message
zookeeper/0*  active    idle   1        10.72.158.122
  otelcol/1*  blocked   idle            10.72.158.122          ['cloud-config']|['grafana-dashboards-provider']|['send-loki-logs']|['send-remote-write'] for cos-agent

Machine  State    Address        Inst id        Base          AZ            Message
1        started  10.72.158.122  juju-50c528-1  ubuntu@22.04  charm-dev-36  Running
```

Notice how in the status we now have a new section named `SAAS`. In that section we can see all the interfaces offered by other applications running in other models that we can integrate to.

We will now relate Opentelemetry Collector to these 3 applications:

```shell
$ juju integrate otelcol prometheus-receive-remote-write
$ juju integrate otelcol loki-logging
$ juju integrate otelcol grafana-dashboards
```

And the three new integrations are established, see the Integrations sections of the model status:

```
$ juju status --relations

Model  Controller  Cloud/Region         Version  SLA          Timestamp
zoo    lxd         localhost/localhost  3.6.19   unsupported  18:33:53-03:00

SAAS                             Status  Store  URL
grafana-dashboards               active  ck8s   admin/cos-lite.grafana-dashboards
loki-logging                     active  ck8s   admin/cos-lite.loki-logging
prometheus-receive-remote-write  active  ck8s   admin/cos-lite.prometheus-receive-remote-write

App        Version  Status  Scale  Charm                    Channel   Rev  Exposed  Message
otelcol    0.130.0  active      1  opentelemetry-collector  2/stable  248  no
zookeeper  3.9.2    active      1  zookeeper                3/stable  163  no

Unit          Workload  Agent  Machine  Public address  Ports  Message
zookeeper/0*  active    idle   1        10.72.158.122
  otelcol/1*  active    idle            10.72.158.122

Machine  State    Address        Inst id        Base          AZ            Message
1        started  10.72.158.122  juju-50c528-1  ubuntu@22.04  charm-dev-36  Running

Integration provider                                  Requirer                              Interface                Type         Message
loki-logging:logging                                  otelcol:send-loki-logs                loki_push_api            regular
otelcol:grafana-dashboards-provider                   grafana-dashboards:grafana-dashboard  grafana_dashboard        regular
otelcol:peers                                         otelcol:peers                         otelcol_replica          peer
prometheus-receive-remote-write:receive-remote-write  otelcol:send-remote-write             prometheus_remote_write  regular
zookeeper:cluster                                     zookeeper:cluster                     cluster                  peer
zookeeper:cos-agent                                   otelcol:cos-agent                     cos_agent                subordinate
zookeeper:restart                                     zookeeper:restart                     rolling_op               peer
zookeeper:upgrade                                     zookeeper:upgrade                     upgrade                  peer
```

## Verify that metrics and logs reach Prometheus and Loki

Now that the Cross Model Relations are established between our application model and our observability model, we can easily verify that the metrics `zookeeper` exposes are reaching Prometheus.

```
$ curl -s http://192.168.1.200/cos-lite-prometheus-0/api/v1/query\?query\=zookeeper_DataDirSize | jq
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "zookeeper_DataDirSize",
          "instance": "localhost:9998",
          "job": "zookeeper_0",
          "juju_application": "zookeeper",
          "juju_model": "zoo",
          "juju_model_uuid": "8bc6571a-11d5-4c14-84a7-7c7c8e50c528",
          "juju_unit": "zookeeper/0",
          "memberType": "Leader",
          "replicaId": "1"
        },
        "value": [
          1776288972.212,
          "551"
        ]
      }
    ]
  }
}
```

You can then log into Grafana, head over to the explore tab, and do the same verification for logs, or check the list of dashboards for the ZooKeeper dashboards.

And with that, you're done! Good job!

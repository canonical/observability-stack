---
myst:
 html_meta:
  description: "Learn to deploy a single-node Canonical Observability Stack on Canonical Kubernetes with S3-backed storage using this reproducible, step-by-step tutorial."
---

# Getting started with COS on Canonical K8s

In this tutorial you deploy a single-node, multi-unit COS, backed by S3 storage.

You can reproduce the COS deployment in this tutorial with a [cloud-config](cos-canonical-k8s-sandbox.conf) script.


## Prerequisites

- A 8cpu16gb node or better, with at least 100GB disk space (see [Sizing guide](../reference/system-requirements) for production deployments).
- Juju v3.6 installed ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-juju/#install-juju)).
- Canonical K8s (snap) installed, with local-storage ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/getting-started/))
  and load-balancer ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-loadbalancer/)) enabled.
  Proxy ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/proxy/)) and
  DNS ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-dns/)) for K8s are configured (if applicable).
- K8s cloud added to Juju ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-clouds/#add-a-kubernetes-cloud)).
- A Juju Kubernetes controller is bootstrapped and ready.


## Set up S3
For S3, we will install the Microceph snap ([doc](https://canonical-microceph.readthedocs-hosted.com/latest/snap/tutorial/get-started/))
and configure RadosGW to listen on port 8080 ([doc](https://canonical-microceph.readthedocs-hosted.com/latest/snap/reference/commands/enable/)).

```{literalinclude} /tutorial/cos-canonical-k8s-sandbox.conf
    :language: bash
    :start-after: [docs:setup-s3]
    :end-before: [docs:setup-s3-end]
    :dedent: 4
```

## Deploy COS using Terraform

Assuming you are using the username `ubuntu`, create a `cos-demo.tf` file as follows:

```{literalinclude} /../tests/integration/cos/tls_internal/track-dev.tf
    :language: hcl
```

**Note**: You can customize further the number of units of each distributed charm and other aspects of COS: have a look at the [`variables.tf`](../../terraform/cos/variables.tf) file of the COS Terraform module for the complete documentation.

To deploy COS in a new model named `cos`, run:

```bash
$ terraform init
$ terraform apply
```

You can watch the model as it settles with:

```
juju status --model cos --relations --watch=5s
```

## Result

The output of `juju status --relations` for your deployment should eventually be very similar to the following:

```
Model  Controller  Cloud/Region  Version  SLA          Timestamp
cos    kub         k8s           3.6.21   unsupported  09:07:33+02:00

App                      Version  Status  Scale  Charm                        Channel      Rev  Address         Exposed  Message
alertmanager             0.31.0   active      1  alertmanager-k8s             dev/edge     203  10.152.183.234  no
ca                                active      1  self-signed-certificates     1/edge       637  10.152.183.51   no
catalogue                         active      1  catalogue-k8s                dev/edge     125  10.152.183.129  no
grafana                  12.4.2   active      1  grafana-k8s                  dev/edge     186  10.152.183.182  no
loki                              active      1  loki-coordinator-k8s         dev/edge      61  10.152.183.219  no       Degraded.
loki-backend             3.7.1    active      1  loki-worker-k8s              dev/edge      68  10.152.183.247  no       backend ready.
loki-read                3.7.1    active      1  loki-worker-k8s              dev/edge      68  10.152.183.139  no       read ready.
loki-s3-integrator                active      1  s3-integrator                2/edge       547  10.152.183.162  no
loki-write               3.7.1    active      1  loki-worker-k8s              dev/edge      68  10.152.183.205  no       write ready.
mimir                             active      1  mimir-coordinator-k8s        dev/edge      81  10.152.183.159  no
mimir-backend            2.17.10  active      1  mimir-worker-k8s             dev/edge      71  10.152.183.196  no       backend ready.
mimir-read               2.17.10  active      1  mimir-worker-k8s             dev/edge      71  10.152.183.246  no       read ready.
mimir-s3-integrator               active      1  s3-integrator                2/edge       547  10.152.183.79   no
mimir-write              2.17.10  active      1  mimir-worker-k8s             dev/edge      71  10.152.183.156  no       write ready.
otelcol                  0.130.1  active      1  opentelemetry-collector-k8s  dev/edge     179  10.152.183.36   no
tempo                             active      1  tempo-coordinator-k8s        dev/edge     149  10.152.183.200  no
tempo-compactor          2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.65   no       compactor ready.
tempo-distributor        2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.252  no       distributor ready.
tempo-ingester           2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.146  no       ingester ready.
tempo-metrics-generator  2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.194  no       metrics-generator ready.
tempo-querier            2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.38   no       querier ready.
tempo-query-frontend     2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.39   no       query-frontend ready.
tempo-s3-integrator               active      1  s3-integrator                2/edge       547  10.152.183.138  no
traefik                  2.11.0   active      1  traefik-k8s                  latest/edge  292  10.152.183.181  no       Serving at http://192.168.178.192

Unit                        Workload  Agent      Address     Ports  Message
alertmanager/0*             active    idle       10.1.0.16
ca/0*                       active    idle       10.1.0.236
catalogue/0*                active    idle       10.1.0.109
grafana/0*                  active    executing  10.1.0.114
loki-backend/0*             active    idle       10.1.0.101         backend ready.
loki-read/0*                active    idle       10.1.0.188         read ready.
loki-s3-integrator/0*       active    idle       10.1.0.78
loki-write/0*               active    idle       10.1.0.7           write ready.
loki/0*                     active    idle       10.1.0.231         Degraded.
mimir-backend/0*            active    idle       10.1.0.245         backend ready.
mimir-read/0*               active    idle       10.1.0.152         read ready.
mimir-s3-integrator/0*      active    idle       10.1.0.135
mimir-write/0*              active    idle       10.1.0.212         write ready.
mimir/0*                    active    idle       10.1.0.51
otelcol/0*                  active    idle       10.1.0.223
tempo-compactor/0*          active    idle       10.1.0.234         compactor ready.
tempo-distributor/0*        active    idle       10.1.0.189         distributor ready.
tempo-ingester/0*           active    idle       10.1.0.41          ingester ready.
tempo-metrics-generator/0*  active    idle       10.1.0.237         metrics-generator ready.
tempo-querier/0*            active    idle       10.1.0.252         querier ready.
tempo-query-frontend/0*     active    idle       10.1.0.124         query-frontend ready.
tempo-s3-integrator/0*      active    idle       10.1.0.46
tempo/0*                    active    idle       10.1.0.67
traefik/0*                  active    idle       10.1.0.222         Serving at http://192.168.178.192

Offer                         Application   Charm                     Rev  Connected  Endpoint              Interface                Role
alertmanager-karma-dashboard  alertmanager  alertmanager-k8s          203  0/0        karma-dashboard       karma_dashboard          provider
certificates                  ca            self-signed-certificates  637  0/0        certificates          tls-certificates         provider
grafana-dashboards            grafana       grafana-k8s               186  0/0        grafana-dashboard     grafana_dashboard        requirer
loki-logging                  loki          loki-coordinator-k8s      61   0/0        logging               loki_push_api            provider
mimir-receive-remote-write    mimir         mimir-coordinator-k8s     81   0/0        receive-remote-write  prometheus_remote_write  provider
send-ca-cert                  ca            self-signed-certificates  637  0/0        send-ca-cert          certificate_transfer     provider

Integration provider                 Requirer                               Interface                    Type     Message
alertmanager:alerting                loki:alertmanager                      alertmanager_dispatch        regular
alertmanager:alerting                mimir:alertmanager                     alertmanager_dispatch        regular
alertmanager:grafana-dashboard       grafana:grafana-dashboard              grafana_dashboard            regular
alertmanager:grafana-source          grafana:grafana-source                 grafana_datasource           regular
alertmanager:replicas                alertmanager:replicas                  alertmanager_replica         peer
alertmanager:self-metrics-endpoint   otelcol:metrics-endpoint               prometheus_scrape            regular
ca:certificates                      alertmanager:certificates              tls-certificates             regular
ca:certificates                      catalogue:certificates                 tls-certificates             regular
ca:certificates                      grafana:certificates                   tls-certificates             regular
ca:certificates                      loki:certificates                      tls-certificates             regular
ca:certificates                      mimir:certificates                     tls-certificates             regular
ca:certificates                      otelcol:receive-server-cert            tls-certificates             regular
ca:certificates                      tempo:certificates                     tls-certificates             regular
ca:send-ca-cert                      traefik:receive-ca-cert                certificate_transfer         regular
catalogue:catalogue                  alertmanager:catalogue                 catalogue                    regular
catalogue:catalogue                  grafana:catalogue                      catalogue                    regular
catalogue:catalogue                  mimir:catalogue                        catalogue                    regular
catalogue:catalogue                  tempo:catalogue                        catalogue                    regular
catalogue:replicas                   catalogue:replicas                     catalogue_replica            peer
grafana:grafana                      grafana:grafana                        grafana_peers                peer
grafana:replicas                     grafana:replicas                       grafana_replicas             peer
loki-s3-integrator:s3-credentials    loki:s3                                s3                           regular
loki-s3-integrator:status-peers      loki-s3-integrator:status-peers        status_peers                 peer
loki:grafana-dashboards-provider     grafana:grafana-dashboard              grafana_dashboard            regular
loki:grafana-source                  grafana:grafana-source                 grafana_datasource           regular
loki:logging                         otelcol:send-loki-logs                 loki_push_api                regular
loki:loki-cluster                    loki-backend:loki-cluster              loki_cluster                 regular
loki:loki-cluster                    loki-read:loki-cluster                 loki_cluster                 regular
loki:loki-cluster                    loki-write:loki-cluster                loki_cluster                 regular
loki:loki-peers                      loki:loki-peers                        loki_peers                   peer
loki:self-metrics-endpoint           otelcol:metrics-endpoint               prometheus_scrape            regular
loki:send-datasource                 tempo:receive-datasource               grafana_datasource_exchange  regular
mimir-s3-integrator:s3-credentials   mimir:s3                               s3                           regular
mimir-s3-integrator:status-peers     mimir-s3-integrator:status-peers       status_peers                 peer
mimir:grafana-dashboards-provider    grafana:grafana-dashboard              grafana_dashboard            regular
mimir:grafana-source                 grafana:grafana-source                 grafana_datasource           regular
mimir:mimir-cluster                  mimir-backend:mimir-cluster            mimir_cluster                regular
mimir:mimir-cluster                  mimir-read:mimir-cluster               mimir_cluster                regular
mimir:mimir-cluster                  mimir-write:mimir-cluster              mimir_cluster                regular
mimir:mimir-peers                    mimir:mimir-peers                      mimir_peers                  peer
mimir:receive-remote-write           otelcol:send-remote-write              prometheus_remote_write      regular
mimir:receive-remote-write           tempo:send-remote-write                prometheus_remote_write      regular
mimir:self-metrics-endpoint          otelcol:metrics-endpoint               prometheus_scrape            regular
mimir:send-datasource                tempo:receive-datasource               grafana_datasource_exchange  regular
otelcol:grafana-dashboards-provider  grafana:grafana-dashboard              grafana_dashboard            regular
otelcol:peers                        otelcol:peers                          otelcol_replica              peer
otelcol:receive-loki-logs            loki:logging-consumer                  loki_push_api                regular
otelcol:receive-loki-logs            mimir:logging-consumer                 loki_push_api                regular
otelcol:receive-loki-logs            tempo:logging                          loki_push_api                regular
otelcol:receive-traces               grafana:charm-tracing                  tracing                      regular
otelcol:receive-traces               loki:charm-tracing                     tracing                      regular
otelcol:receive-traces               mimir:charm-tracing                    tracing                      regular
tempo-s3-integrator:s3-credentials   tempo:s3                               s3                           regular
tempo-s3-integrator:status-peers     tempo-s3-integrator:status-peers       status_peers                 peer
tempo:grafana-dashboard              grafana:grafana-dashboard              grafana_dashboard            regular
tempo:grafana-source                 grafana:grafana-source                 grafana_datasource           regular
tempo:metrics-endpoint               otelcol:metrics-endpoint               prometheus_scrape            regular
tempo:peers                          tempo:peers                            tempo_peers                  peer
tempo:tempo-cluster                  tempo-compactor:tempo-cluster          tempo_cluster                regular
tempo:tempo-cluster                  tempo-distributor:tempo-cluster        tempo_cluster                regular
tempo:tempo-cluster                  tempo-ingester:tempo-cluster           tempo_cluster                regular
tempo:tempo-cluster                  tempo-metrics-generator:tempo-cluster  tempo_cluster                regular
tempo:tempo-cluster                  tempo-querier:tempo-cluster            tempo_cluster                regular
tempo:tempo-cluster                  tempo-query-frontend:tempo-cluster     tempo_cluster                regular
tempo:tracing                        otelcol:send-traces                    tracing                      regular
traefik:ingress                      alertmanager:ingress                   ingress                      regular
traefik:ingress                      catalogue:ingress                      ingress                      regular
traefik:ingress                      grafana:ingress                        ingress                      regular
traefik:ingress                      loki:ingress                           ingress                      regular
traefik:ingress                      mimir:ingress                          ingress                      regular
traefik:peers                        traefik:peers                          traefik_peers                peer
traefik:traefik-route                otelcol:ingress                        traefik_route                regular
traefik:traefik-route                tempo:ingress                          traefik_route                regular

Storage Unit               Storage ID         Type        Pool        Mountpoint                              Size     Status    Message
alertmanager/0             data/2             filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-ed7c4ba4-45f3-473d-b215-2d1de8cb4efb
grafana/0                  database/1         filesystem  kubernetes  /var/lib/juju/storage/database/0        1.0 GiB  attached  Successfully provisioned volume pvc-946789ef-bc4d-461d-bf0d-975676caf164
loki-backend/0             loki-persisted/12  filesystem  kubernetes  /var/lib/juju/storage/loki-persisted/0  1.0 GiB  attached  Successfully provisioned volume pvc-b5a5aba5-4c3e-4a1c-8a5e-7c2452691286
loki-read/0                loki-persisted/11  filesystem  kubernetes  /var/lib/juju/storage/loki-persisted/0  1.0 GiB  attached  Successfully provisioned volume pvc-d2c2df79-494a-44d8-a669-c8d7feb521dc
loki-write/0               loki-persisted/10  filesystem  kubernetes  /var/lib/juju/storage/loki-persisted/0  1.0 GiB  attached  Successfully provisioned volume pvc-18f51f63-8128-4410-8b4e-f8b8245cca08
mimir-backend/0            data/6             filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-5f61a2f9-afb6-4b19-a9e1-de43de2f2910
mimir-backend/0            recovery-data/7    filesystem  kubernetes  /var/lib/juju/storage/recovery-data/0   1.0 GiB  attached  Successfully provisioned volume pvc-3979cc73-61a9-4245-b21d-88c9f91de794
mimir-read/0               data/8             filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-c4e5b1ce-dba4-40ea-b285-cad49f9e1102
mimir-read/0               recovery-data/9    filesystem  kubernetes  /var/lib/juju/storage/recovery-data/0   1.0 GiB  attached  Successfully provisioned volume pvc-3125cad4-d0e4-4b51-9ed8-2ac22e00ce18
mimir-write/0              data/4             filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-027b9f8e-4f52-415e-8c5e-6c0c1a262466
mimir-write/0              recovery-data/5    filesystem  kubernetes  /var/lib/juju/storage/recovery-data/0   1.0 GiB  attached  Successfully provisioned volume pvc-32c2da54-8d11-4648-9f34-6fd1bc0813f5
otelcol/0                  persisted/3        filesystem  kubernetes  /var/lib/juju/storage/persisted/0       1.0 GiB  attached  Successfully provisioned volume pvc-8a47075e-7065-4f1f-9f7d-489a0ec670b4
tempo-compactor/0          wal/14             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-82aa6366-e774-439f-9712-dcdac3754055
tempo-distributor/0        wal/18             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-ed9dcd00-f9ea-4e6e-a84f-6e7f5db3cd56
tempo-ingester/0           wal/13             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-31de1ee4-f5aa-4601-b58d-564b48c84885
tempo-metrics-generator/0  wal/15             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-d421642f-73cc-47b8-a513-970ade3dd403
tempo-querier/0            wal/16             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-0d9ab88b-be01-4bb2-9dc6-073619b38260
tempo-query-frontend/0     wal/17             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-1cc70846-155f-4393-acbb-eb6279e11077
traefik/0                  configurations/0   filesystem  kubernetes  /var/lib/juju/storage/configurations/0  1.0 GiB  attached  Successfully provisioned volume pvc-fc8dfaef-889a-4ec7-9834-1abffdaea04d
```

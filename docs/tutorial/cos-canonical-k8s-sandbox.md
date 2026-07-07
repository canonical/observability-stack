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

Create a `cos-demo.tf` file as follows:

```{literalinclude} /../tests/integration/cos/tls_internal/track-dev.tf
    :language: hcl
```

**Note**: You can customize further the number of units of each distributed charm and other aspects of COS: have a look at the [`variables.tf`](../../terraform/cos/variables.tf) file of the COS Terraform module for the complete documentation.

To deploy COS in a new model named `cos`, run:

```bash
terraform init
terraform apply -var="model=cos" \
  -var="s3_endpoint=$IPADDR" \
  -var="s3_secret_key=secret-key" \
  -var="s3_access_key=access-key"
```

You can watch the model as it settles:

```
juju status --model cos --relations --watch=5s
```

## Result

The output of `juju status --relations` for your deployment should eventually be very similar to the following:

```
Model  Controller  Cloud/Region  Version  SLA          Timestamp
cos    ck8s        ck8s          3.6.21   unsupported  12:14:38+02:00

App                      Version  Status  Scale  Charm                        Channel      Rev  Address         Exposed  Message
alertmanager             0.31.0   active      1  alertmanager-k8s             dev/edge     206  10.152.183.104  no
ca                                active      1  self-signed-certificates     1/edge       637  10.152.183.157  no
catalogue                         active      1  catalogue-k8s                dev/edge     125  10.152.183.162  no
grafana                  12.4.2   active      1  grafana-k8s                  dev/edge     187  10.152.183.83   no
loki                              active      1  loki-coordinator-k8s         dev/edge      61  10.152.183.88   no       Degraded.
loki-backend             3.7.1    active      1  loki-worker-k8s              dev/edge      68  10.152.183.90   no       backend ready.
loki-read                3.7.1    active      1  loki-worker-k8s              dev/edge      68  10.152.183.211  no       read ready.
loki-s3-integrator                active      1  s3-integrator                2/edge       550  10.152.183.129  no
loki-write               3.7.1    active      1  loki-worker-k8s              dev/edge      68  10.152.183.217  no       write ready.
mimir                             active      1  mimir-coordinator-k8s        dev/edge      81  10.152.183.220  no
mimir-backend            2.17.10  active      1  mimir-worker-k8s             dev/edge      71  10.152.183.212  no       backend ready.
mimir-read               2.17.10  active      1  mimir-worker-k8s             dev/edge      71  10.152.183.227  no       read ready.
mimir-s3-integrator               active      1  s3-integrator                2/edge       550  10.152.183.100  no
mimir-write              2.17.10  active      1  mimir-worker-k8s             dev/edge      71  10.152.183.193  no       write ready.
otelcol                  0.130.1  active      1  opentelemetry-collector-k8s  dev/edge     179  10.152.183.115  no
tempo                             active      1  tempo-coordinator-k8s        dev/edge     149  10.152.183.117  no
tempo-compactor          2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.200  no       compactor ready.
tempo-distributor        2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.228  no       distributor ready.
tempo-ingester           2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.92   no       ingester ready.
tempo-metrics-generator  2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.183  no       metrics-generator ready.
tempo-querier            2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.137  no       querier ready.
tempo-query-frontend     2.10.1   active      1  tempo-worker-k8s             dev/edge     102  10.152.183.20   no       query-frontend ready.
tempo-s3-integrator               active      1  s3-integrator                2/edge       550  10.152.183.216  no
traefik                  2.11.0   active      1  traefik-k8s                  latest/edge  294  10.152.183.182  no       Serving at http://10.249.85.241

Unit                        Workload  Agent      Address     Ports  Message
alertmanager/0*             active    idle       10.1.0.112
ca/0*                       active    idle       10.1.0.180
catalogue/0*                active    idle       10.1.0.186
grafana/0*                  active    idle       10.1.0.169
loki-backend/0*             active    idle       10.1.0.142         backend ready.
loki-read/0*                active    idle       10.1.0.225         read ready.
loki-s3-integrator/0*       active    idle       10.1.0.96
loki-write/0*               active    idle       10.1.0.229         write ready.
loki/0*                     active    idle       10.1.0.69          Degraded.
mimir-backend/0*            active    idle       10.1.0.218         backend ready.
mimir-read/0*               active    idle       10.1.0.88          read ready.
mimir-s3-integrator/0*      active    idle       10.1.0.64
mimir-write/0*              active    idle       10.1.0.43          write ready.
mimir/0*                    active    idle       10.1.0.57
otelcol/0*                  active    idle       10.1.0.121
tempo-compactor/0*          active    idle       10.1.0.109         compactor ready.
tempo-distributor/0*        active    idle       10.1.0.30          distributor ready.
tempo-ingester/0*           active    idle       10.1.0.155         ingester ready.
tempo-metrics-generator/0*  active    idle       10.1.0.124         metrics-generator ready.
tempo-querier/0*            active    idle       10.1.0.106         querier ready.
tempo-query-frontend/0*     active    idle       10.1.0.114         query-frontend ready.
tempo-s3-integrator/0*      active    idle       10.1.0.81
tempo/0*                    active    idle       10.1.0.107
traefik/0*                  active    idle       10.1.0.135         Serving at http://10.249.85.241

Offer                         Application   Charm                     Rev  Connected  Endpoint              Interface                Role
alertmanager-karma-dashboard  alertmanager  alertmanager-k8s          206  0/0        karma-dashboard       karma_dashboard          provider
certificates                  ca            self-signed-certificates  637  0/0        certificates          tls-certificates         provider
grafana-dashboards            grafana       grafana-k8s               187  0/0        grafana-dashboard     grafana_dashboard        requirer
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
otelcol:receive-loki-logs            alertmanager:logging                   loki_push_api                regular
otelcol:receive-loki-logs            grafana:logging                        loki_push_api                regular
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
alertmanager/0             data/1             filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-306b0833-5c2a-4270-ba20-fac620b8b5be
grafana/0                  database/3         filesystem  kubernetes  /var/lib/juju/storage/database/0        1.0 GiB  attached  Successfully provisioned volume pvc-b37d7f49-0b5a-409f-8e5b-56a57d212598
loki-backend/0             loki-persisted/12  filesystem  kubernetes  /var/lib/juju/storage/loki-persisted/0  1.0 GiB  attached  Successfully provisioned volume pvc-9b92a901-ac30-4e26-a9c0-81692aecef8c
loki-read/0                loki-persisted/6   filesystem  kubernetes  /var/lib/juju/storage/loki-persisted/0  1.0 GiB  attached  Successfully provisioned volume pvc-d24b4519-f3f6-4cc7-b595-7d4c3bb19d75
loki-write/0               loki-persisted/13  filesystem  kubernetes  /var/lib/juju/storage/loki-persisted/0  1.0 GiB  attached  Successfully provisioned volume pvc-4d8a0605-9cad-415a-b55d-f96bc561bb4f
mimir-backend/0            data/7             filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-c2335bbf-0b4b-4509-be45-e6915af0cb87
mimir-backend/0            recovery-data/8    filesystem  kubernetes  /var/lib/juju/storage/recovery-data/0   1.0 GiB  attached  Successfully provisioned volume pvc-ca30d59d-210c-466a-9b0e-956f0b0fc875
mimir-read/0               data/10            filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-bf7e55a0-f530-47a6-8db8-82f67353bf60
mimir-read/0               recovery-data/11   filesystem  kubernetes  /var/lib/juju/storage/recovery-data/0   1.0 GiB  attached  Successfully provisioned volume pvc-f05111ec-90d4-4d34-b46c-11665f25cbd6
mimir-write/0              data/4             filesystem  kubernetes  /var/lib/juju/storage/data/0            1.0 GiB  attached  Successfully provisioned volume pvc-f15365ba-cc3c-46ac-b770-5baa060091c7
mimir-write/0              recovery-data/5    filesystem  kubernetes  /var/lib/juju/storage/recovery-data/0   1.0 GiB  attached  Successfully provisioned volume pvc-4d0af7f9-ae4c-4396-b047-d5d26bf1de7c
otelcol/0                  persisted/2        filesystem  kubernetes  /var/lib/juju/storage/persisted/0       1.0 GiB  attached  Successfully provisioned volume pvc-64e14ebe-2e64-484a-9fc1-486d42e5c57c
tempo-compactor/0          wal/18             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-d51e4cf4-5ffe-4ffa-b291-d6973b7a1f3f
tempo-distributor/0        wal/9              filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-493ddbc3-6db7-4212-8eac-24f113c34417
tempo-ingester/0           wal/16             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-02b1e04d-af1e-4103-af93-350186f93a1c
tempo-metrics-generator/0  wal/14             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-008f0c76-fbd1-4862-b116-f2a116c6f68f
tempo-querier/0            wal/15             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-5b12acbb-af86-471c-8875-2196276cbcd5
tempo-query-frontend/0     wal/17             filesystem  kubernetes  /var/lib/juju/storage/wal/0             1.0 GiB  attached  Successfully provisioned volume pvc-e5cde942-0ada-4dc8-9ade-fe6989d1f7a0
traefik/0                  configurations/0   filesystem  kubernetes  /var/lib/juju/storage/configurations/0  1.0 GiB  attached  Successfully provisioned volume pvc-5930d32c-7909-4d81-b039-ab45c3461200
```

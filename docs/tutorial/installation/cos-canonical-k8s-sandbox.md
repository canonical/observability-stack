# Getting started with COS on Canonical K8s

In this tutorial you deploy a single-node, multi-unit COS, backed by S3 storage.

You can reproduce the COS deployment in this tutorial with a [cloud-config](cos-canonical-k8s-sandbox.conf) script.


## Prerequisites
- A 8cpu16gb node or better, with at least 100GB disk space
- Juju v3.6 installed ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-juju/#install-juju)).
- Canonical K8s (snap) installed, with local-storage ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/getting-started/))
  and load-balancer ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-loadbalancer/)) enabled.
  Proxy ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/proxy/)) and
  DNS ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-dns/)) for K8s are configured (if applicable).
- K8s cloud added to Juju ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-clouds/#add-a-kubernetes-cloud)).
- A Juju Kubernetes controller is bootstrapped and ready.


## Set up S3
For S3, we will install the Microceph snap ([doc](https://canonical-microceph.readthedocs-hosted.com/latest/tutorial/get-started/))
and configure RadosGW to listen on port 8080 ([doc](https://canonical-microceph.readthedocs-hosted.com/latest/reference/commands/enable/)).

```{literalinclude} /tutorial/installation/cos-canonical-k8s-sandbox.conf
    :language: bash
    :start-after: [docs:setup-s3]
    :end-before: [docs:setup-s3-end]
    :dedent: 4
```

### Create buckets for Loki, Mimir and Tempo

```{literalinclude} /tutorial/installation/cos-canonical-k8s-sandbox.conf
    :language: bash
    :start-after: [docs:create-buckets]
    :end-before: [docs:create-buckets-end]
    :dedent: 4
```

## Deploy COS using Terraform

Assuming you are using the username `ubuntu`, create a `cos-demo.tf` file as follows:

```{literalinclude} /tutorial/installation/cos-canonical-k8s-sandbox.conf
    :language: bash
    :start-after: [docs:create-terraform-module]
    :end-before: [docs:create-terraform-module-end]
    :dedent: 4
```

**Note**: You can customize further the number of units of each distributed charm and other aspects of COS: have a look at the [`variables.tf`](../../../terraform/cos/variables.tf) file of the COS Terraform module for the complete documentation.

<!-- TODO: Add TLS relations with both internal and external CAs. -->

To deploy COS in a new model named `cos`, run:

```bash
juju add-model cos
terraform init
terraform apply
```

You can watch the model as it settles with:
```
juju status --model cos --relations --watch=5s
```

## Result

The output of `juju status --relations` for your deployment should eventually be very similar to the following:

```
Model  Controller  Cloud/Region  Version  SLA          Timestamp
cos    ck8s        ck8s          3.6.7    unsupported  10:55:15-00:00

App                      Version  Status  Scale  Charm                  Channel        Rev  Address         Exposed  Message
alertmanager             0.27.0   active      1  alertmanager-k8s       2/edge         171  10.152.183.180  no       
catalogue                         active      1  catalogue-k8s          2/edge          94  10.152.183.145  no       
grafana                  9.5.3    active      1  grafana-k8s            2/edge         155  10.152.183.144  no       
grafana-agent            0.40.4   active      1  grafana-agent-k8s      2/edge         148  10.152.183.251  no       grafana-dashboards-provider: off
loki                              active      3  loki-coordinator-k8s   2/edge          35  10.152.183.128  no       
loki-backend             3.0.0    active      3  loki-worker-k8s        2/edge          48  10.152.183.22   no       backend ready.
loki-read                3.0.0    active      3  loki-worker-k8s        2/edge          48  10.152.183.161  no       read ready.
loki-s3-integrator                active      1  s3-integrator          2/edge         157  10.152.183.159  no       
loki-write               3.0.0    active      3  loki-worker-k8s        2/edge          48  10.152.183.188  no       write ready.
mimir                             active      3  mimir-coordinator-k8s  2/edge          57  10.152.183.187  no       
mimir-backend            2.13.0   active      3  mimir-worker-k8s       2/edge          55  10.152.183.168  no       backend ready.
mimir-read               2.13.0   active      3  mimir-worker-k8s       2/edge          55  10.152.183.129  no       read ready.
mimir-s3-integrator               active      1  s3-integrator          2/edge         157  10.152.183.184  no       
mimir-write              2.13.0   active      3  mimir-worker-k8s       2/edge          55  10.152.183.225  no       write ready.
tempo                             active      3  tempo-coordinator-k8s  2/edge          91  10.152.183.123  no       
tempo-compactor          2.7.1    active      3  tempo-worker-k8s       2/edge          66  10.152.183.138  no       compactor ready.
tempo-distributor        2.7.1    active      3  tempo-worker-k8s       2/edge          66  10.152.183.27   no       distributor ready.
tempo-ingester           2.7.1    active      3  tempo-worker-k8s       2/edge          66  10.152.183.91   no       ingester ready.
tempo-metrics-generator  2.7.1    active      3  tempo-worker-k8s       2/edge          66  10.152.183.200  no       metrics-generator ready.
tempo-querier            2.7.1    active      3  tempo-worker-k8s       2/edge          66  10.152.183.59   no       querier ready.
tempo-query-frontend     2.7.1    active      3  tempo-worker-k8s       2/edge          66  10.152.183.109  no       query-frontend ready.
tempo-s3-integrator               active      1  s3-integrator          2/edge         157  10.152.183.205  no       
traefik                  2.11.0   active      1  traefik-k8s            latest/stable  236  10.152.183.197  no       Serving at 10.63.93.138

Unit                        Workload  Agent  Address     Ports  Message
alertmanager/0*             active    idle   10.1.0.38          
catalogue/0*                active    idle   10.1.0.2           
grafana-agent/0*            active    idle   10.1.0.242         grafana-dashboards-provider: off
grafana/0*                  active    idle   10.1.0.108         
loki-backend/0              active    idle   10.1.0.154         backend ready.
loki-backend/1              active    idle   10.1.0.162         backend ready.
loki-backend/2*             active    idle   10.1.0.140         backend ready.
loki-read/0*                active    idle   10.1.0.187         read ready.
loki-read/1                 active    idle   10.1.0.169         read ready.
loki-read/2                 active    idle   10.1.0.235         read ready.
loki-s3-integrator/0*       active    idle   10.1.0.72          
loki-write/0*               active    idle   10.1.0.115         write ready.
loki-write/1                active    idle   10.1.0.239         write ready.
loki-write/2                active    idle   10.1.0.182         write ready.
loki/0                      active    idle   10.1.0.35          
loki/1*                     active    idle   10.1.0.90          
loki/2                      active    idle   10.1.0.10          
mimir-backend/0*            active    idle   10.1.0.3           backend ready.
mimir-backend/1             active    idle   10.1.0.24          backend ready.
mimir-backend/2             active    idle   10.1.0.147         backend ready.
mimir-read/0*               active    idle   10.1.0.103         read ready.
mimir-read/1                active    idle   10.1.0.112         read ready.
mimir-read/2                active    idle   10.1.0.158         read ready.
mimir-s3-integrator/0*      active    idle   10.1.0.171         
mimir-write/0*              active    idle   10.1.0.160         write ready.
mimir-write/1               active    idle   10.1.0.155         write ready.
mimir-write/2               active    idle   10.1.0.96          write ready.
mimir/0                     active    idle   10.1.0.117         
mimir/1                     active    idle   10.1.0.222         
mimir/2*                    active    idle   10.1.0.134         
tempo-compactor/0*          active    idle   10.1.0.204         compactor ready.
tempo-compactor/1           active    idle   10.1.0.191         compactor ready.
tempo-compactor/2           active    idle   10.1.0.181         compactor ready.
tempo-distributor/0         active    idle   10.1.0.53          distributor ready.
tempo-distributor/1         active    idle   10.1.0.176         distributor ready.
tempo-distributor/2*        active    idle   10.1.0.184         distributor ready.
tempo-ingester/0            active    idle   10.1.0.221         ingester ready.
tempo-ingester/1            active    idle   10.1.0.78          ingester ready.
tempo-ingester/2*           active    idle   10.1.0.109         ingester ready.
tempo-metrics-generator/0   active    idle   10.1.0.13          metrics-generator ready.
tempo-metrics-generator/1*  active    idle   10.1.0.40          metrics-generator ready.
tempo-metrics-generator/2   active    idle   10.1.0.201         metrics-generator ready.
tempo-querier/0*            active    idle   10.1.0.118         querier ready.
tempo-querier/1             active    idle   10.1.0.195         querier ready.
tempo-querier/2             active    idle   10.1.0.197         querier ready.
tempo-query-frontend/0*     active    idle   10.1.0.17          query-frontend ready.
tempo-query-frontend/1      active    idle   10.1.0.180         query-frontend ready.
tempo-query-frontend/2      active    idle   10.1.0.12          query-frontend ready.
tempo-s3-integrator/0*      active    idle   10.1.0.247         
tempo/0*                    active    idle   10.1.0.217         
tempo/1                     active    idle   10.1.0.84          
tempo/2                     active    idle   10.1.0.249         
traefik/0*                  active    idle   10.1.0.127         Serving at 10.63.93.138

Offer                         Application   Charm                  Rev  Connected  Endpoint              Interface                Role
alertmanager-karma-dashboard  alertmanager  alertmanager-k8s       171  0/0        karma-dashboard       karma_dashboard          provider
grafana-dashboards            grafana       grafana-k8s            155  0/0        grafana-dashboard     grafana_dashboard        requirer
loki-logging                  loki          loki-coordinator-k8s   35   0/0        logging               loki_push_api            provider
mimir-receive-remote-write    mimir         mimir-coordinator-k8s  57   0/0        receive-remote-write  prometheus_remote_write  provider
```

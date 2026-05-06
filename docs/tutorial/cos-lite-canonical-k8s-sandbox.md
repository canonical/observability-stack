---
myst:
 html_meta:
  description: "Learn to deploy a single-node COS Lite appliance on Canonical Kubernetes with hostPath storage in this practical tutorial for lightweight observability." 
---

# Getting started with COS Lite on Canonical K8s

In this tutorial you deploy a single-node COS Lite appliance, backed by hostPath storage.

## Prerequisites

- A 4cpu8gb node or better, with at least 40Gi disk space (see [Sizing guide](../reference/system-requirements) for production deployments).
- Juju v3.6 installed ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-juju/#install-juju)).
- Canonical K8s (snap) installed, with local-storage ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/getting-started/))
  and load-balancer ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-loadbalancer/)) enabled.
- Proxy ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/proxy/)) and
  DNS ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-dns/)) for K8s are configured (if applicable).
- K8s cloud added to Juju ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-clouds/#add-a-kubernetes-cloud)).


## Deploy COS Lite with Terraform

To deploy the COS Lite solution in a model named `cos-lite`, create this root module:


```{literalinclude} cos-lite.tf
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```


You can watch the model as it settles with:

```bash
$ juju status --relations --watch=5s
```

The status of your deployment should eventually be very similar to the following:

```
$ juju status --relations --storage

Model     Controller  Cloud/Region  Version  SLA          Timestamp
cos-lite  kub         k8s           3.6.21   unsupported  11:39:52+02:00

App           Version  Status  Scale  Charm                     Channel      Rev  Address         Exposed  Message
alertmanager  0.31.0   active      1  alertmanager-k8s          dev/edge     202  10.152.183.170  no
ca                     active      1  self-signed-certificates  1/edge       637  10.152.183.71   no
catalogue              active      1  catalogue-k8s             dev/edge     125  10.152.183.24   no
grafana       12.4.2   active      1  grafana-k8s               dev/edge     186  10.152.183.59   no
loki          3.7.1    active      1  loki-k8s                  dev/edge     226  10.152.183.29   no
prometheus    3.11.1   active      1  prometheus-k8s            dev/edge     292  10.152.183.104  no
traefik       2.11.0   active      1  traefik-k8s               latest/edge  292  10.152.183.108  no       Serving at http://192.168.178.192

Unit             Workload  Agent      Address     Ports  Message
alertmanager/0*  active    idle       10.1.0.207
ca/0*            active    idle       10.1.0.155
catalogue/0*     active    idle       10.1.0.193
grafana/0*       active    idle       10.1.0.229
loki/0*          active    idle       10.1.0.133
prometheus/0*    active    idle       10.1.0.83
traefik/0*       active    idle       10.1.0.93          Serving at http://192.168.178.192

Offer                            Application   Charm                     Rev  Connected  Endpoint              Interface                Role
alertmanager-karma-dashboard     alertmanager  alertmanager-k8s          202  0/0        karma-dashboard       karma_dashboard          provider
certificates                     ca            self-signed-certificates  637  0/0        certificates          tls-certificates         provider
grafana-dashboards               grafana       grafana-k8s               186  0/0        grafana-dashboard     grafana_dashboard        requirer
loki-logging                     loki          loki-k8s                  226  0/0        logging               loki_push_api            provider
prometheus-metrics-endpoint      prometheus    prometheus-k8s            292  0/0        metrics-endpoint      prometheus_scrape        requirer
prometheus-receive-remote-write  prometheus    prometheus-k8s            292  0/0        receive-remote-write  prometheus_remote_write  provider
send-ca-cert                     ca            self-signed-certificates  637  0/0        send-ca-cert          certificate_transfer     provider

Integration provider                Requirer                     Interface              Type     Message
alertmanager:alerting               loki:alertmanager            alertmanager_dispatch  regular
alertmanager:alerting               prometheus:alertmanager      alertmanager_dispatch  regular
alertmanager:grafana-dashboard      grafana:grafana-dashboard    grafana_dashboard      regular
alertmanager:grafana-source         grafana:grafana-source       grafana_datasource     regular
alertmanager:replicas               alertmanager:replicas        alertmanager_replica   peer
alertmanager:self-metrics-endpoint  prometheus:metrics-endpoint  prometheus_scrape      regular
ca:certificates                     alertmanager:certificates    tls-certificates       regular
ca:certificates                     catalogue:certificates       tls-certificates       regular
ca:certificates                     grafana:certificates         tls-certificates       regular
ca:certificates                     loki:certificates            tls-certificates       regular
ca:certificates                     prometheus:certificates      tls-certificates       regular
ca:send-ca-cert                     traefik:receive-ca-cert      certificate_transfer   regular
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
traefik:ingress                     grafana:ingress              ingress                regular
traefik:ingress-per-unit            loki:ingress                 ingress_per_unit       regular
traefik:ingress-per-unit            prometheus:ingress           ingress_per_unit       regular
traefik:metrics-endpoint            prometheus:metrics-endpoint  prometheus_scrape      regular
traefik:peers                       traefik:peers                traefik_peers          peer

Storage Unit    Storage ID                Type        Pool        Mountpoint                                      Size     Status    Message
alertmanager/0  data/8                    filesystem  kubernetes  /var/lib/juju/storage/data/0                    1.0 GiB  attached  Successfully provisioned volume pvc-cf00986d-5428-467b-89f9-a0788e996702
grafana/0       database/6                filesystem  kubernetes  /var/lib/juju/storage/database/0                1.0 GiB  attached  Successfully provisioned volume pvc-eddf2615-6147-4e78-8224-fcf69e8080c5
loki/0          active-index-directory/4  filesystem  kubernetes  /var/lib/juju/storage/active-index-directory/0  1.0 GiB  attached  Successfully provisioned volume pvc-3d7b9b8d-1d50-469c-b5ad-94201e517d41
loki/0          loki-chunks/5             filesystem  kubernetes  /var/lib/juju/storage/loki-chunks/0             1.0 GiB  attached  Successfully provisioned volume pvc-aa88c858-aa5f-4981-8330-7eb8245ea581
prometheus/0    database/3                filesystem  kubernetes  /var/lib/juju/storage/database/0                1.0 GiB  attached  Successfully provisioned volume pvc-e8ae59b8-e046-4041-9a44-9bde5b9950ae
traefik/0       configurations/2          filesystem  kubernetes  /var/lib/juju/storage/configurations/0          1.0 GiB  attached  Successfully provisioned volume pvc-29e9fd9a-b787-4056-9cd3-5135b6a1c442
```

Now COS Lite is good to go: you can relate software with it to begin the monitoring!

Obtain the Grafana admin password,

```bash
juju run grafana/leader get-admin-password
```

then head over to the URL listed in the outputm and use the provided password to log in.
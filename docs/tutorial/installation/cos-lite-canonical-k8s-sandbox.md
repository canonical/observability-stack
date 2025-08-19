# Getting started with COS Lite on Canonical K8s

In this tutorial you deploy a single-node COS Lite appliance, backed by hostPath storage.

You can reproduce the entire tutorial with a [cloud-config](cos-lite-canonical-k8s-sandbox.conf) script.

## Prerequisites
- A 4cpu8gb node or better, with at least 40Gi disk space.
- Juju v3.6 installed ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-juju/#install-juju)).
- Canonical K8s (snap) installed, with local-storage ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/getting-started/))
  and load-balancer ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-loadbalancer/)) enabled.
- Proxy ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/proxy/)) and
  DNS ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-dns/)) for K8s are configured (if applicable).
- K8s cloud added to Juju ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-clouds/#add-a-kubernetes-cloud)).


## Deploy the COS Lite bundle

It is usually a good idea to create a dedicated model for the COS Lite bundle. So let's do just that and call the new model `cos`:

Create a new juju model, `cos`:

```bash
$ juju add-model cos
```

Next, deploy the bundle with:

```bash
$ juju deploy cos-lite --trust
```

You can watch the model as it settles with:

```bash
$ juju status --relations --watch=5s
```

The status of your deployment should eventually be very similar to the following:

```
$ juju status --relations --storage
Model  Controller  Cloud/Region  Version  SLA          Timestamp
cos    ck8s        ck8s          3.6.6    unsupported  16:44:44-04:00

App           Version  Status  Scale  Charm             Channel        Rev  Address         Exposed  Message
alertmanager  0.27.0   active      1  alertmanager-k8s  1/stable       160  10.152.183.253  no       
catalogue              active      1  catalogue-k8s     1/stable        81  10.152.183.181  no       
grafana       9.5.3    active      1  grafana-k8s       1/stable       143  10.152.183.152  no       
loki          2.9.6    active      1  loki-k8s          1/stable       190  10.152.183.176  no       
prometheus    2.52.0   active      1  prometheus-k8s    latest/stable  234  10.152.183.54   no       
traefik       2.11.0   active      1  traefik-k8s       latest/stable  236  10.152.183.56   no       Serving at 10.63.93.172

Unit             Workload  Agent  Address     Ports  Message
alertmanager/0*  active    idle   10.1.0.221         
catalogue/0*     active    idle   10.1.0.225         
grafana/0*       active    idle   10.1.0.129         
loki/0*          active    idle   10.1.0.72          
prometheus/0*    active    idle   10.1.0.60          
traefik/0*       active    idle   10.1.0.65          Serving at 10.63.93.172

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

Storage Unit    Storage ID                Type        Pool        Mountpoint                                      Size     Status    Message
alertmanager/0  data/0                    filesystem  kubernetes  /var/lib/juju/storage/data/0                    1.0 GiB  attached  Successfully provisioned volume pvc-eb1dc923-32a0-4729-9ec8-694b50672987
grafana/0       database/1                filesystem  kubernetes  /var/lib/juju/storage/database/0                1.0 GiB  attached  Successfully provisioned volume pvc-b5df8210-671a-4ed6-a083-3fe50e3c6fdc
loki/0          active-index-directory/2  filesystem  kubernetes  /var/lib/juju/storage/active-index-directory/0  1.0 GiB  attached  Successfully provisioned volume pvc-af183528-4399-42c2-ae59-94e71e1a18c9
loki/0          loki-chunks/3             filesystem  kubernetes  /var/lib/juju/storage/loki-chunks/0             1.0 GiB  attached  Successfully provisioned volume pvc-86caedeb-e0a5-438f-9ab9-d118f5629723
prometheus/0    database/4                filesystem  kubernetes  /var/lib/juju/storage/database/0                1.0 GiB  attached  Successfully provisioned volume pvc-eaece84a-5b45-4f08-b82f-5eb07163d637
traefik/0       configurations/5          filesystem  kubernetes  /var/lib/juju/storage/configurations/0          1.0 GiB  attached  Successfully provisioned volume pvc-4b1da33c-e66f-42bf-a12f-4ac11806a63a
```

Now COS Lite is good to go: you can relate software with it to begin the monitoring!

## Add "offers" to enable cross-model relations

Download the [offers](https://github.com/canonical/cos-lite-bundle/blob/main/overlays/offers-overlay.yaml)
[overlay](https://canonical-charmcraft.readthedocs-hosted.com/en/stable/reference/files/bundle-yaml-file/),

```bash
curl -L https://raw.githubusercontent.com/canonical/cos-lite-bundle/main/overlays/offers-overlay.yaml -O
```

 and update the deployment:

```bash
juju deploy cos-lite --trust --overlay ./offers-overlay.yaml
```

This enables [cross-model relations](https://documentation.ubuntu.com/juju/3.6/reference/relation/#cross-model-relation).
In the output of `juju status` you should now see the following new section:

```
Offer                            Application   Charm             Rev  Connected  Endpoint              Interface                Role
alertmanager-karma-dashboard     alertmanager  alertmanager-k8s  160  0/0        karma-dashboard       karma_dashboard          provider
grafana-dashboards               grafana       grafana-k8s       143  0/0        grafana-dashboard     grafana_dashboard        requirer
loki-logging                     loki          loki-k8s          190  0/0        logging               loki_push_api            provider
prometheus-receive-remote-write  prometheus    prometheus-k8s    234  0/0        receive-remote-write  prometheus_remote_write  provider
```


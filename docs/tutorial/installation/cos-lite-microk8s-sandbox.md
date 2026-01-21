# Getting started with COS Lite on MicroK8s

In this tutorial you deploy a single-node COS Lite appliance, backed by hostPath storage.

## Prerequisites

This tutorial assumes you have a Juju controller bootstrapped on a 
MicroK8s cloud that is ready to use, on a 4cpu8gb node or better, with at least 40Gi disk space.
Typical setup using [snaps](https://snapcraft.io/) 
can be found in the [Juju docs](https://documentation.ubuntu.com/juju/3.6/howto/manage-your-deployment/).

Follow the instructions there to install Juju and MicroK8s.

## Introduction

The [COS Lite bundle](https://charmhub.io/cos-lite) is a Juju-based observability stack, running on Kubernetes. The bundle consists of 
[Prometheus](https://charmhub.io/prometheus-k8s), 
[Loki](https://charmhub.io/loki-k8s), 
[Alertmanager](https://charmhub.io/alertmanager-k8s), and 
[Grafana](https://charmhub.io/grafana-k8s).

Let's go and deploy that bundle!

## Configure MicroK8s

For the COS Lite bundle deployment to go smoothly, make sure the following MicroK8s [addons](https://microk8s.io/docs/addons) are enabled: `dns`, `hostpath-storage` and `metallb`.

You can check this with `microk8s status`, and if any are missing, enable them with 

```bash
$ microk8s enable dns 
```

```{note}
While the following setup is sufficient for non-production environments, if you're looking for a more resilient storage option,
consider deploying MicroCeph on MicroK8s using this [guide](https://microk8s.io/docs/how-to-ceph).
```

```bash
$ microk8s enable hostpath-storage
```

The bundle comes with Traefik to provide ingress, for which you'll need a load balancer controller.
If you don't have one already, the `metallb` add-on should be enabled:

```bash 
$ IPADDR=$(ip -4 -j route get 2.2.2.2 | jq -r '.[] | .prefsrc')
$ microk8s enable metallb:$IPADDR-$IPADDR
```

To wait for all the addons to be rolled out, then run:

```bash
$ microk8s kubectl rollout status deployments/hostpath-provisioner -n kube-system -w
$ microk8s kubectl rollout status deployments/coredns -n kube-system -w
$ microk8s kubectl rollout status daemonset.apps/speaker -n metallb-system -w
```

```{note}
If you have an HTTP proxy configured, you will need to give this information to MicroK8s. See [the proxy documentation](https://microk8s.io/docs/install-proxy) for details.
```

```{note} 
By default, MicroK8s will use `8.8.8.8` and `8.8.4.4` as DNS servers, which can be adjusted. See [the DNS documentation](https://microk8s.io/docs/addon-dns) for details.
```

## Deploy the COS Lite bundle

It is usually a good idea to create a dedicated model for the COS Lite bundle. So let's do just that and call the new model `cos`:

```bash
$ juju add-model cos
$ juju switch cos
```

Next, deploy the bundle with:

```bash
$ juju deploy cos-lite --trust
```

Now you can sit back and watch the deployment take place:

```bash
$ juju status --relations --watch=5s
```

The status of your deployment should eventually be very similar to the following:

```
$ juju status --relations
Model  Controller  Cloud/Region        Version  SLA          Timestamp
cos    microk8s    microk8s/localhost  3.6.4    unsupported  15:48:47+04:00

App           Version  Status  Scale  Charm             Channel      Rev  Address         Exposed  Message
alertmanager  0.27.0   active      1  alertmanager-k8s  latest/edge  158  10.152.183.34   no       
catalogue              active      1  catalogue-k8s     latest/edge   83  10.152.183.128  no       
grafana       9.5.3    active      1  grafana-k8s       latest/edge  146  10.152.183.110  no       
loki          2.9.6    active      1  loki-k8s          latest/edge  193  10.152.183.108  no       
prometheus    2.52.0   active      1  prometheus-k8s    latest/edge  240  10.152.183.55   no       
traefik       2.11.0   active      1  traefik-k8s       latest/edge  236  10.152.183.211  no       Serving at 10.211.88.149

Unit             Workload  Agent  Address      Ports  Message
alertmanager/0*  active    idle   10.1.157.91         
catalogue/0*     active    idle   10.1.157.81         
grafana/0*       active    idle   10.1.157.93         
loki/0*          active    idle   10.1.157.92         
prometheus/0*    active    idle   10.1.157.94         
traefik/0*       active    idle   10.1.157.90         Serving at 10.211.88.149

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

Now COS Lite is good to go: you can relate software with it to begin the monitoring!

Alternatively, you may want to deploy the bundle with one or more of our readily available 
overlays, which is what we'll cover next.

## Deploy the COS Lite bundle with overlays

An [overlay](https://documentation.ubuntu.com/charmcraft/stable/reference/files/bundle-yaml-file/) is a set of model-specific modifications
that avoid repetitive overhead in setting up bundles like COS Lite.

Specifically, we offer the following overlays:

- the [offers overlay](https://github.com/canonical/cos-lite-bundle/blob/main/overlays/offers-overlay.yaml) 
  makes your COS model ready for [cross-model relations](https://documentation.ubuntu.com/juju/3.6/reference/relation/#cross-model-relation)

- the [storage-small overlay](https://github.com/canonical/cos-lite-bundle/blob/main/overlays/storage-small-overlay.yaml)
  applies some defaults for the various storage used by the COS Lite components.

```{note}
You can apply the `offers` overlay to an existing COS Lite bundle by executing the `juju deploy` command.
The `storage-small` overlay, however, is applicable only on the first deployment.
So, if you were following the previous steps you would first need to switch to a new Juju model or remove all applications from the current one.
```

To use any of the overlays above, you need to include an `--overlay` argument per overlay (applied in order):

```bash
$ curl -L https://raw.githubusercontent.com/canonical/cos-lite-bundle/main/overlays/offers-overlay.yaml -O
$ curl -L https://raw.githubusercontent.com/canonical/cos-lite-bundle/main/overlays/storage-small-overlay.yaml -O
$ juju deploy cos-lite \
        --trust \
        --overlay ./offers-overlay.yaml \
        --overlay ./storage-small-overlay.yaml
```

(deploy-cos-ref)=

## Deploy COS Lite using Terraform

Create a `cos-lite-microk8s-sandbox.tf` file with the following Terraform module, or include it in your Terraform plan:

```{literalinclude} /tutorial/installation/cos-lite-microk8s-sandbox.tf
```

<!-- if Field wants, allow setting `anti_affinity` by something other than `kubernetes/hostname` -->

**Note**: You can customize further the revisions of each charm and other aspects of COS Lite: have a look at the [`variables.tf`](../../../terraform/cos/variables.tf) file of the COS Lite Terraform module for the complete documentation.

<!-- Once we allow enabling internal TLS and external TLS separately, add the explanation to this tutorial -->

It is usually a good idea to create a dedicated model for COS Lite. This module creates one named `cos`, which you can override.

Next, deploy COS Lite in the new model, run:

```bash
$ terraform init
$ terraform apply  # verify the changes you're applying before accepting!
```

Now you can sit back and watch the deployment take place:

```bash
$ juju switch cos
$ juju status --relations --watch=5s
```

## Browse dashboards

When all the charms are deployed you can head over to browse their built-in web interfaces. You can find out their 
addresses from the [show-proxied-endpoints](https://charmhub.io/traefik-k8s/actions#show-proxied-endpoints) 
Traefik action.

For example:

```bash
$ juju run traefik/0 show-proxied-endpoints --format=yaml \
        | yq '."traefik/0".results."proxied-endpoints"' \
        | jq
```

...should return output similar to:

```json
{
    "prometheus/0": {
        "url": "http://10.43.8.34:80/cos-prometheus-0"
    },
    "loki/0": {
        "url": "http://10.43.8.34:80/cos-loki-0"
    },
    "catalogue": {
        "url": "http://10.43.8.34:80/cos-catalogue"
    },
    "alertmanager": {
        "url": "http://10.43.8.34:80/cos-alertmanager"
    }
}
```

In the output above, 
- `10.43.8.34` is Traefik's IP address.
- Applications that are ingresses "per app", such as Alertmanager, are 
  accessible via the `model-app` path (i.e. `http://10.43.8.34:80/cos-alertmanager`).
- Applications that are ingresses "per unit", such as Loki, are accessible via 
  the `model-app-unit` path (i.e. `http://10.43.8.34:80/cos-loki-0`).

Note that Grafana does not appear in the list. Currently, to obtain Grafana's 
proxied endpoint you would need to look at catalogue's relation data directly - try running:

```bash
$ juju show-unit catalogue/0 | grep url
```

...which should return a list of the endpoints like this:

```bash
url: http://10.43.8.34:80/cos-catalogue
url: http://10.43.8.34/cos-grafana
url: http://10.43.8.34:80/cos-prometheus-0
url: http://10.43.8.34:80/cos-alertmanager
```


With ingress in place, you can still access the workloads via pod IPs, but you will need 
to include the original port, as well as the ingress path. For example:

```
$ curl 10.1.55.34:9093/cos-alertmanager/-/ready
```

The default password for Grafana is automatically generated for every installation. To 
access Grafana's web interface, use the username `admin`, and the password obtained 
from the [`get-admin-password`](https://charmhub.io/grafana-k8s/actions) action, e.g:

```bash
$ juju run grafana/leader get-admin-password --model cos
```

Enjoy!

## Next steps

- Use the [scrape target charm](https://charmhub.io/prometheus-scrape-target-k8s) to 
  have the COS stack scrape any Prometheus compatible target.
- Relate your own charm to the COS stack with relation interfaces such as 
  [prometheus_scrape](https://charmhub.io/prometheus-k8s/libraries/prometheus_scrape).
- [Configure alertmanager](https://prometheus.io/docs/alerting/latest/configuration/)
  to have alerts routed to your receivers.
- Use the [cos-proxy machine charm](https://charmhub.io/cos-proxy) to observe 
  LMA-enabled machine charms.
- Use the [grafana-agent machine charm](https://charmhub.io/grafana-agent) to observe 
  charms on other substrates than Kubernetes. 

If you need support, the [Charmhub community](https://discourse.charmhub.io) is the best 
place to get all your questions answered and get in touch with the community.

## Further reading

- [Model-driven observability: modern monitoring with Juju](https://ubuntu.com/blog/model-driven-observability-part-1)

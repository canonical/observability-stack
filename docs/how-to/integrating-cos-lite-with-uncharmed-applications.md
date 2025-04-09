# Integrating COS Lite with uncharmed applications

The [COS Lite bundle](https://github.com/canonical/cos-lite-bundle) is designed to 
be deployed and operated using Juju. However, not all workloads that you may want 
to monitor will be. The good news is that you can use  `cos-lite` to monitor 
workloads that are not charmed (aka "not managed by Juju"). The bad news is that 
it's relatively straightforward to do so. Not bad at all.

## Prerequisites

This how-to assumes that you already have a working deployment of COS Lite. If that is not the case, we recommend you first follow our [tutorial for getting started with COS Lite](/tutorial/installation/getting-started-with-cos-lite).

The first step will be to get a hold of a machine, somewhere, and follow 
[this guide on how to get started with COS lite on MicroK8s](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s). 

Unless you're also planning to monitor some charmed applications with this cos-lite deployment, you will **not** need to use [the offers overlay](https://charmhub.io/topics/canonical-observability-stack/tutorials/install-microk8s#heading--deploy-the-cos-lite-bundle-with-overlays). 

## Deploy the Grafana Agent

The Grafana agent will act as an intermediary between the applications you want to monitor and the `cos-lite` stack. It will gather telemetry from your applications 
and send them to `cos-lite`, where you will be able to inspect them through the 
Grafana dashboards.

We recommend to host the Grafana agent as close as possible to the workloads you 
intend to monitor, to minimize the risk of network faults and the resulting gaps 
in telemetry collection.

We recommend to install the Grafana agent via a handy snap we maintain:

```bash
$ sudo snap install grafana-agent
```

```{note}
Grafana agent is also available as a single Go binary, and you are free to install it and run it the way you like. See the [official documentation](https://grafana.com/docs/agent/latest/) for the publisher's recommendations and guides. We also have it [containerized](https://github.com/canonical/grafana-agent-rock/pkgs/container/grafana-agent) and [petrified](https://github.com/canonical/grafana-agent-rock/).
```

Now that you have Grafana Agent up and running, you will need to configure it.

## Get the API endpoints

COS Lite includes a Traefik instance that takes care of load balancing and 
providing ingress capabilities to the various observability components of the stack. Since `cos-lite` 
runs on Kubernetes, this allows you to talk to them via `traefik` over a stable 
URL.

```{caution}

Before you can use Traefik from an external service such as Grafana agent, you will need to ensure that the Traefik URL is routable from the service host, and that the address is stable. (e.g. not a dynamic IP)

In other words, Traefik's own URL needs to be stable.
```

In the Juju model where COS Lite is deployed, run the command below to find out the URL to the proxied endpoint.

```
$ juju run traefik/0 show-proxied-endpoints
```

Assuming you have [configured the Traefik charm](https://github.com/canonical/traefik-k8s-operator#configurations) to use an external host name, for example `"traefik.url"`, you will see something like:

```
proxied-endpoints: '{
    "prometheus/0": {"url": "https://traefik.url/mymodel-prometheus-0"},
    "loki/0": {"url": "https://traefik.url/mymodel-loki-0"},
    "alertmanager": {"url": "https://traefik.url/mymodel-alertmanager"},
    "catalogue": {"url": "https://traefik.url/mymodel-catalogue"},
}'
```

If you prefer to explore the deployment in a graphical manner, you can also 
open `https://traefik.url/mymodel-catalogue` in a browser for a list of all the 
user interfaces of the components included.

At this point you will need to follow [the documentation on how to configure the Grafana agent](https://grafana.com/docs/agent/latest/static/configuration/#configure-static-mode). Use the URLs you obtained from Traefik to tell the agent where to send its telemetry.

Once you've written your finished configuration to `/etc/grafana-agent.yaml`, you'll 
be able to restart the snap using the following command:

```bash
$ sudo snap restart grafana-agent
```

And with that, you are done! Good job, you got this!

## Diving deeper

If completing this how-to guide made you crave for me, feel free to continue on with one of the following extracurriculars.

### Custom dashboards and alerts

If you want to add your own dashboards and alerts to COS Lite you may extend your
COS Lite deployment with the [COS Configuration charm](https://github.com/canonical/cos-configuration-k8s-operator).

This charm allow you to use a GitOps-type of workflow for continuously feeding 
your COS deployment with your latest alert and dashboard definitions.

See [this guide](https://github.com/canonical/cos-configuration-k8s-operator#deployment) for more information.

### Using TLS

You can deploy cos-lite with the [TLS](https://github.com/canonical/cos-lite-bundle/pull/80) overlay to enable secure communications with and within COS Lite. 

You can follow [this guide](https://charmhub.io/traefik-k8s/docs/tls-termination) to enable TLS in Traefik and COS Lite.

### Using the Prometheus-scrape-target charm

In some rare circumstances, you might prefer to use `prometheus-scrape-target` instead of `grafana-agent`. Namely:

- When you only need metrics (no logs, traces, etc...)
- When you'd rather make the necessary firewall changes in the workload you want to monitor, than ingress cos-lite
- When you lack permissions to install snaps on the server hosting the workload you want to monitor

If this describes your situation, you can opt for deploying the [Prometheus scrape-target charm](https://github.com/canonical/prometheus-scrape-target-k8s-operator) charm instead, configuring it to scrape your workload.


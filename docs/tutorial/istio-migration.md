# Migrating from Traefik to Istio

In this guide, you will learn how to migrate the Canonical Observability Stack from using Traefik as its ingress to
using Istio. Istio is a service mesh which allows you to secure and control all the network traffic on your cluster.
For more info on Istio, you can [browse the docs](https://canonical-service-mesh-documentation.readthedocs-hosted.com/latest/).

## Prerequisites

* [Kubernetes](https://documentation.ubuntu.com/canonical-kubernetes/latest/)
* [Juju](https://documentation.ubuntu.com/juju/)
* The [Canonical Observability Stack](https://link-to-cos-docs)

```{note}
The Istio charms work with Microk8s out of box. If you are using Canonical Kubernetes, see [these instructions](https://canonical-service-mesh-documentation.readthedocs-hosted.com/latest/how-to/use-charmed-istio-with-canonical-kubernetes/). If you are using any other flavor of Kubernetes, see the [Istio docs](https://istio.io/latest/docs/setup/platform-setup/).
```

```{note}
COS 2 does not have support for service mesh. To use service mesh, you must deploy cos from track 3 or greater or from dev.
```

## Steps

* Install Istio on the cluster

```{code} bash
juju add-model istio-system
juju deploy istio-k8s istio --channel dev/edge --trust
```
Once the charm settles, Your cluster is ready to use Istio.

* Switch back to the cos model

```{code} bash
juju switch cos
```

* Remove the Traefik charm

```{code} bash
juju remove-application traefik
```

* Now we install the istio-beacon charm. By relating all of the COS apps to the beacon, we put them on the mesh so that their network traffic becomes controlled by Istio.

```{code} bash
juju deploy istio-beacon-k8s istio-beacon --channel dev/edge --trust
juju integrate istio-beacon:service-mesh alertmanager
juju integrate istio-beacon:service-mesh catalogue
juju integrate istio-beacon:service-mesh grafana
juju integrate istio-beacon:service-mesh loki
juju integrate istio-beacon:service-mesh mimir
juju integrate istio-beacon:service-mesh otelcol
juju integrate istio-beacon:service-mesh tempo
```
You will need to wait a while for the model to settle but it should all reach active/idle eventually.

* Now all of our charms are on the mesh, but we still have no ingress set up. So we install the istio-ingress charm.

```{code} bash
juju deploy istio-ingress-k8s istio-ingress --channel dev/edge --trust
juju relate istio-ingress:ingress alertmanager
juju relate istio-ingress:ingress catalogue
juju relate istio-ingress:ingress grafana
juju relate istio-ingress:ingress loki
juju relate istio-ingress:ingress mimir
juju relate istio-ingress:istio-ingress-route otelcol
juju relate istio-ingress:istio-ingress-route tempo
```
Once again you will need to wait some time for this to settle.

* Your migration is not complete. To make sure everything is working navigate to `http://\<ingress-adress\>/cos-catalogue` and check that everything is still working.

* To view all of the network policies created, view the authorization policies

```{code} bash
kubectl get ap
```

# Networking Best Practices

## Ingress

MetalLB, or an equivalent load balancer, should be configured on the Kubernetes environment.
COS and COS Lite use Traefik to provide network ingress for the stack components.
Make sure the load balancer provides Traefik with **a static IP**, or some other identity that remains stable over time.

## Egress
Some charms require external connectivity to function correctly.

As a common requirement, the environment should be able to reach:
* Charmhub;
* the Juju registry;
* Snapcraft.

There are other charm-specific URLs that some charms access by default:
* `https://objects.githubusercontent.com/`, needed by [Loki](https://charmhub.io/loki-k8s/docs/network);
* `stats.grafana.org`, needed by [Grafana](https://charmhub.io/grafana-k8s/docs/network-requirements) and
  [Grafana Agent](https://charmhub.io/grafana-k8s/docs/network-requirements).

To disable the functionalities that require those URLs, please refer to linked docs for the relevant charms.

## Controller routing

If the network topology is anything other than flat, the Juju controllers will need to be bootstrapped with
`--controller-external-ips`, `--controller-external-name`, or both, so that the controllers are able to communicate over
routable identities for your cross--controller relations. For example:

```
juju bootstrap microk8s uk8s \
  --config controller-service-type=loadbalancer \
  --config controller-external-ips=[10.0.0.2]
```

Note that these config values can only be set at bootstrap time, and are read-only thereafter.


## Juju relation topology

### Avoid pulling data cross-model

Cross-model relations using the `prometheus_scrape` interface should be avoided.
Instead, deploy a Grafana agent in each of the models you want to observe and let the agents be a fan-in point pushing the data to COS Lite.
This makes for a less error-prone networking topology that is easier to reason about, especially at scale.

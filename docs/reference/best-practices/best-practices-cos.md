# Deployment Best Practices

## Support window
Refer to [Supported tracks](supported-tracks) to choose the right track for your needs.
Note that different tracks may have different ubuntu bases or minimum Juju version requirement.


## Storage

### Evaluate storage volume needs
Evaluate the [telemetry volume needed](../how-to/evaluate-telemetry-volume) for your solution
and refer to the storage [sizing guideline](https://discourse.charmhub.io/t/cos-lite-ingestion-limits-for-8cpu-16gb-ssd/13005) for concrete numbers.

For example, a deployment that handles roughly:

- 1M metrics/min from 150 targets; and
- 100k log lines/min for about 150 targets

has a growth rate of about 50GB per day under normal operations.
So, if you want a retention interval of about two months, you'll need 3TB of storage only for the telemetry.

### Set up distributed storage
In production, **do not** use hostPath storage ([`hostpath-storage`](https://microk8s.io/docs/addon-hostpath-storage) in MicroK8s; `local-storage` in Canonical K8s):
 * `PersistentVolumeClaims` created by the host path storage provisioner are bound to the local node, so it is *impossible to move them to a different node*.
 * A `hostpath` volume can *grow beyond the capacity set in the volume claim manifest*.

#### Canonical K8s
Use ceph-csi. Refer to Canonical Kubernetes [snap](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/storage/ceph/)
and [charm](https://documentation.ubuntu.com/canonical-kubernetes/latest/charm/howto/ceph-csi/) docs.

#### MicroK8s
Use the [`rook-ceph`](https://microk8s.io/docs/addon-rook-ceph) add-on together with Microceph.
See the [Microceph tutorial](https://microk8s.io/docs/how-to-ceph).


## Networking

### Ingress

MetalLB, or an equivalent load balancer, should be configured on the Kubernetes environment COS is running on.
COS and COS Lite use Traefik to provide network ingress for the stack components.
Make sure the load balancer provides Traefik with **a static IP**, or some other identity that remains stable over time.

### Egress
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

#### Controller routing

If the network topology is anything other than flat, the Juju controllers will need to be bootstrapped with
`--controller-external-ips`, `--controller-external-name`, or both, so that the controllers are able to communicate over
routable identities for your cross--controller relations. For example:

```
juju bootstrap microk8s uk8s \
  --config controller-service-type=loadbalancer \
  --config controller-external-ips=[10.0.0.2]
```

Note that these config values can only be set at bootstrap time, and are read-only thereafter.


## Deployment topology
Deploy in isolation. COS (or COS Lite) should at the very least be deployed in its own Juju model, but preferably even on a separate substrate with a dedicated Juju controller.

```{mermaid}
flowchart LR

subgraph Infra A
A[Your workloads] -->|telemetry| otelcol["OpenTelemetry Collector<br/>(or Grafana Agent)"]
end

subgraph Infra B
B(COS)
end

subgraph Infra C
C[COS Alerter]
end

otelcol-->|telemetry| B
B -->|heartbeat| C
```

[COS Alerter](https://github.com/canonical/cos-alerter) should be deployed to let operators know whenever the routing of notifications from COS Lite stops working,
preventing a false sense of security. We advise to deploy COS Alerter on dedicated infra, separate from the COS Lite infra.

These precautions help to limit the blast radius in case of outages in the workloads you observe, or the observability stack itself.


### Reliability

For COS, deploy at least three nodes per worker, with anti-affinity set to hostname.

For COS Lite, we **strongly** recommend using [a separate three-node MicroK8s cluster](https://microk8s.io/docs/high-availability).


## Juju relation topology
#### Avoid pulling data cross-model

Cross-model relations using the `prometheus_scrape` interface should be avoided.
Instead, deploy a Grafana agent in each of the models you want to observe and let the agents be a fan-in point pushing the data to COS.
This makes for a less error-prone networking topology that is easier to reason about, especially at scale.


## Maintenance
Before restarting a Kubernetes node with COS applications on it, you should cordon and drain it so that the StatefulSets are moved to another node.
This process will ensure the least amount of downtime.

In the event that a node goes down unexpectedly and cannot be recovered, you can manually recover the COS units by force deleting the pod and any
volume attachments that existed on the inaccessible node. The pods will then be rescheduled to a working node.


### Known issues
- High availability during maintenance is only possible on clusters utilizing distributed storage, such as MicroCeph.
- All of the COS applications use StatefulSets, so these pods will not self-heal and deploy to another node automatically.
- The juju controller needs to be up for COS pods to start, otherwise their charm container will fail, causing the pod to go into a crash loop.


## Upgrading
Remember to `juju refresh` with `--trust`. If omitted, you would need to `juju trust X --scope=cluster`.

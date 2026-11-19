---
myst:
  html_meta:
    description: "How to deploy Charmed Pyroscope, configure TLS, and integrate Pyroscope charms using the 'profiling' interface."
---

# How to use Charmed Pyroscope

This page covers:

- [How to deploy Charmed Pyroscope](#how-to-deploy-charmed-pyroscope): deploy the coordinator and worker charms, using Terraform or manually.
- [How to enable TLS for Charmed Pyroscope](#how-to-enable-tls-for-charmed-pyroscope): terminate TLS at the coordinator's NGINX.
- [How to integrate with charmed Pyroscope over `profiling`](#how-to-integrate-with-charmed-pyroscope-over-profiling): send profiles from charmed or uncharmed applications.

## How to deploy Charmed Pyroscope

Pyroscope HA consists of two charms: 
- [`pyroscope-coordinator-k8s`](../../explanation/architecture/peripheral-charms/charmed-pyroscope-ha.md#pyroscope-coordinator-charm), responsible for the ingress and cluster coordination
- [`pyroscope-worker-k8s`](../../explanation/architecture/peripheral-charms/charmed-pyroscope-ha.md#pyroscope-worker-charm), which runs the actual workloads. 

*Requirements*: Pyroscope requires an object storage backend (such as Ceph). Typically, that will be through the `s3-integrator` charm.

### Using Terraform

There is a Terraform module that can be used to deploy Pyroscope HA in [the Pyroscope charm repository](https://github.com/canonical/pyroscope-operators/tree/main/terraform).

#### Prerequisites

Before applying the Terraform plan, you need to have your object storage ready together with an endpoint it can be reached over. The following example uses the `minio` charm, deployed in the same model. Its application IP (`http://10.152.183.18:9000`) is used as the S3 endpoint URL.

#### Deployment 

In your Terraform repository, create a `pyroscope` module:

```hcl
module "pyroscope" {
  source      = "git::https://github.com/canonical/pyroscope-operators//terraform"
  model       = var.model
  channel     = var.channel
  s3_endpoint = var.s3_endpoint
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key
}
```

Add relevant input variables to your `variables.tf`, then run `terraform apply`.

```{note}
Currently the `2/edge` channel should be used to deploy Charmed Pyroscope. We'll be releasing the `stable` track in future once the full profiling flow including Pyroscope and OpenTelemetry Collector stabilizes. See the [profiles mappings](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/profiles/mappings.md) specification for details of profiles support in OpenTelemetry.
```

Eventually the model should settle and you'll get a `juju status` output similar to the following:

```
$ juju status
Model           Controller  Cloud/Region        Version  SLA          Timestamp
test-big-terra  microk8s    microk8s/localhost  3.6.7    unsupported  11:03:47+02:00

App                        Version                Status  Scale  Charm                      Channel        Rev  Address         Exposed  Message
minio                      res:oci-image@7f2474f  active      1  minio                      ckf-1.10/edge  459  10.152.183.18   no       
pyroscope                                         active      1  pyroscope-coordinator-k8s  2/edge          19  10.152.183.198  no       Degraded.
pyroscope-ad-hoc-profiles  ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.174  no       ad-hoc-profiles ready.
pyroscope-compactor        ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.163  no       compactor ready.
pyroscope-distributor      ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.64   no       distributor ready.
pyroscope-ingester         ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.123  no       ingester ready.
pyroscope-querier          ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.157  no       querier ready.
pyroscope-query-frontend   ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.190  no       query-frontend ready.
pyroscope-query-scheduler  ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.154  no       query-scheduler ready.
pyroscope-s3-integrator                           active      1  s3-integrator              2/edge         157  10.152.183.184  no       
pyroscope-store-gateway    ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.173  no       store-gateway ready.
pyroscope-tenant-settings  ...                    active      1  pyroscope-worker-k8s       2/edge          12  10.152.183.52   no       tenant-settings ready.

Unit                          Workload  Agent  Address       Ports          Message
minio/0*                      active    idle   10.1.157.108  9000-9001/TCP  
pyroscope-ad-hoc-profiles/0*  active    idle   10.1.157.127                 ad-hoc-profiles ready.
pyroscope-compactor/0*        active    idle   10.1.157.72                  compactor ready.
pyroscope-distributor/0*      active    idle   10.1.157.96                  distributor ready.
pyroscope-ingester/0*         active    idle   10.1.157.81                  ingester ready.
pyroscope-querier/0*          active    idle   10.1.157.77                  querier ready.
pyroscope-query-frontend/0*   active    idle   10.1.157.80                  query-frontend ready.
pyroscope-query-scheduler/0*  active    idle   10.1.157.105                 query-scheduler ready.
pyroscope-s3-integrator/0*    active    idle   10.1.157.102                 
pyroscope-store-gateway/0*    active    idle   10.1.157.101                 store-gateway ready.
pyroscope-tenant-settings/0*  active    idle   10.1.157.79                  tenant-settings ready.
pyroscope/0*                  active    idle   10.1.157.106                 Degraded.
```

#### Customizing the deployment

By default, the deployment will create one worker unit for every required role. You can fine-tune that to your needs using terraform input variables. See [Inputs](https://github.com/canonical/pyroscope-operators/tree/main/terraform#inputs) for the full list of available configurations.

### Monolithic deployment mode for testing and dev

If you want just to experiment with Pyroscope, you can also manually deploy it in monolithic mode, which means having a single worker with the `all` role (which is the default), instead of the one-worker-application-per-role distributed mode. You will still need an object storage backend and `s3-integrator` pointing at the s3 endpoint. 

```bash
juju deploy pyroscope-coordinator-k8s pyroscope --channel=2/edge --trust
juju deploy pyroscope-worker-k8s pyroscope-worker --channel=2/edge --trust
juju relate pyroscope pyroscope-worker
juju relate pyroscope s3-integrator
```

## How to enable TLS for Charmed Pyroscope

Before enabling TLS, make sure you have deployed charmed Pyroscope.
See the [How to deploy Charmed Pyroscope](#how-to-deploy-charmed-pyroscope) guide for instructions.

### Deploy a certificates provider

For this example, we will use the [self-signed-certificates](https://charmhub.io/self-signed-certificates) charm, but you can use any other charm that provides the [`tls-certificates`](https://charmhub.io/integrations/tls-certificates) interface:

```bash
juju deploy self-signed-certificates ssc 
```

### Integrate with Pyroscope

Then, integrate the coordinator with self-signed-certificates

```bash
juju integrate pyroscope:certificates ssc
```

Now, Charmed Pyroscope will be running over *NGINX-terminated TLS.*

```{note}
Upstream Pyroscope [does not yet support TLS](https://github.com/grafana/pyroscope/issues/3598).
Charmed Pyroscope uses *NGINX TLS termination* at the coordinator, which means:
- Requests from clients to the coordinator are encrypted over TLS.
- Requests forwarded from the coordinator to worker charms are unsecured.

If you need e2e TLS, keep an eye out on [adding service mesh support to Pyroscope](https://github.com/canonical/istio-beacon-k8s-operator/issues/90)
```

## How to integrate with charmed Pyroscope over `profiling` 

Suppose you have an application capable of emitting Pyroscope-compatible profiles (e.g. using one of the instrumentation SDKs) and a charmed Pyroscope deployment. 
If not, refer to the [How to deploy Charmed Pyroscope](#how-to-deploy-charmed-pyroscope) guide for instructions.

### If the application is charmed

Charms can integrate with [`pyroscope-coordinator-k8s`](../../explanation/architecture/peripheral-charms/charmed-pyroscope-ha.md#pyroscope-coordinator-charm) (or [`opentelemetry-collector`](https://charmhub.io/opentelemetry-collector)) over the `profiling` interface to receive an endpoint URL where they can push profiles to using the `otlp-grpc` format.

See the [`profiling` charm library docs](https://charmhub.io/pyroscope-coordinator-k8s/libraries/profiling) for exhaustive usage and API documentation.

### If the application is not charmed

Uncharmed applications can be configured to send profiles directly to a [`pyroscope-coordinator-k8s`](../../explanation/architecture/peripheral-charms/charmed-pyroscope-ha.md#pyroscope-coordinator-charm) application (or `opentelemtry-collector`) by using their juju-managed addresses directly.

For example if you have a model where the [`pyroscope-coordinator-k8s`](../../explanation/architecture/peripheral-charms/charmed-pyroscope-ha.md#pyroscope-coordinator-charm) application is available at `<IP address>`, you can manually configure your application to send profiles to `<IP address>:8080`.

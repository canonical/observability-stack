# Getting started with COS on Canonical K8s

In this tutorial you deploy a multi-node COS solution, backed by s3 storage. The s3 storage is assumed to be already deployed.

You can reproduce the COS deployment with a [Terraform module](cos-canonical-k8s-sandbox.tf).

## Prerequisites

- You should have at least three 8-cpu 16GB-RAM nodes, with at least 100GB disk space
- Juju v3.6 installed ([doc](https://documentation.ubuntu.com/juju/3.6/howto/manage-juju/#install-juju))
- ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/proxy/)) and ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-dns/)) for K8s are configured (if applicable)
- Canonical K8s is already installed and configured ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/getting-started/))
- You have in Ingress controller (for Canonical K8s, it’s Cilium) installed and configured ([doc](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/networking/default-loadbalancer/))
- `ceph` with `radosgw` are up and running, and we know their address. S3 access and secret keys already exist
- `ceph-csi` was already added to Kubernetes (meaning we’re not using hostPath storage)

## Deploy COS using Terraform

Create a `cos-canonical-k8s-sandbox.tf` file with the following Terraform module, or include it in your Terraform plan:

```{literalinclude} /tutorial/installation/cos-canonical-k8s-sandbox.tf
```

<!-- warn users of the 2 Juju Provider bugs -->
<!-- add `enable_external_tls` when available -->
<!-- probably set the default track in the COS module to `1/stable`, then remove the key from the tutorial -->
<!-- if Field wants, allow setting `anti_affinity` by something other than `kubernetes/hostname` -->

**Note**: You can customize further the number of units of each distributed charm and other aspects of COS: have a look at the [`variables.tf`](../../../terraform/cos/variables.tf) file of the COS Terraform module for the complete documentation.

<!-- Once we allow enabling internal TLS and external TLS separately, add the explanation to this tutorial -->

To deploy COS on a new model, run:

```bash
terraform init
terraform apply  ./cos-canonical-k8s-sandbox.md  # verify the changes you're applying before accepting!
```

You can watch the model as it settles with:
```
juju status --model cos --relations --watch=5s
```

The status of your deployment should eventually be very similar to the following:

```
insert final cos deployment
```

## Add offers to enable cross-model relations

TODO: Soon we'll have these in Terraform automatically; when that happens, remove this section and simply explain that.

Run the following:
```bash
juju offer traefik:receive-ca-cert
juju offer grafana:receive-ca-cert
# do we need more offers like for Mimir, Loki etc?
```

The status of your deployment now should look like:

`panic.jpg`


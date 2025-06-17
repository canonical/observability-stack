# TLS encryption in COS

## COS

When deploying COS using [the provided Terraform module](https://github.com/canonical/observability-stack/tree/main/terraform/cos), it will by default be deployed using a self-signed certificate authority. If you have other certificate requirements, you'll be able to replace the self-signed-certificates operator with another TLS operator of your liking, consulting the "Providing" section of [the `tls-certificates` interface page on Charmhub](https://charmhub.io/integrations/tls-certificates).

## COS Lite

COS Lite can be deployed unencrypted, with TLS termination only, or end-to-end encrypted.

### Unencrypted COS Lite

The [cos-lite bundle](https://charmhub.io/cos-lite) deploys COS with workloads communicating using plain HTTP (unencrypted).

### TLS-terminated COS Lite

The Traefik charm can function as a TLS termination point by relating it to an external CA (integrator) charm. Within the COS model, charms would still communicate using plain HTTP (unencrypted).

### COS Lite with end-to-end TLS

The cos-lite bundle together with the TLS overlay deploy an end-to-end encrypted COS.
- COS charms generate CSRs with the K8s FQDN as the SAN DNS and the internal CA signs.
- All COS charms trust the internal CA by installing the CA certificate in the charm and workload containers, using the `update-ca-certificates` tool.
- The external CA provides a certificate for Traefik's external URL.
- Within the COS model, workloads communicate via K8s FQDN URLs.
- Requests coming from outside of the model, use the ingress URLs.
- Traefik is able to establish a secure connection with its proxied apps thanks to trusting the local CA.

Note: currently there is a [known issue](https://github.com/canonical/operator/issues/970) due to which some COS relations are limited to in-cluster relations only.

The end-to-end COS TLS design is described in the diagram below. The diagram is limited to prometheus and alertmanager for brevity and clarity.

![TLS](assets/tls-diagram.png)

As with any TLS configuration, keep in mind best practices such as frequent certificate rotation.  See [this guide](https://charmhub.io/blackbox-exporter-k8s/docs/monitor-ssl-certificates) for an example of monitoring certificates.
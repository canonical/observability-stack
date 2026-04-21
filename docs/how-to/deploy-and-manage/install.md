---
myst:
 html_meta:
   description: "Install the Canonical Observability Stack: preparation checklist covering sizing, networking, storage, and deployment options."
---

# How to install COS

## Preparation

Before deploying COS or COS Lite, work through the items below.

### COS flavor

The [flavor of COS](/explanation/overview/what-is-cos) to install depends on your use-case.
If you want to install on edge devices, then COS Lite is likely the right choice; otherwise
you should probably go with "full" COS.

```{mermaid}
graph LR

subgraph env["Monitored environment"]
opentelemetry-collector
end

subgraph k8s["K8s cluster"]
COS
end

subgraph pc["Public cloud"]
cos-alerter["COS Alerter"]
end

subgraph storage["Storage cluster"]
S3
end

opentelemetry-collector ---|telemetry| COS
COS --- S3
COS --- cos-alerter
```

### Sizing

Use the [sizing guide](/reference/system-requirements) to determine the minimum hardware for your deployment.
If you don't yet know how much telemetry your workloads generate, start with [How to evaluate telemetry volume](/how-to/configure-and-tune/evaluate-telemetry-volume).

Follow the [storage best practices](/reference/storage) to set up a distributed storage backend.
Do **not** use `hostPath` storage in production.

### Configure networking

Review the [networking best practices](/reference/networking) and ensure:

- A load balancer (for example, MetalLB) is available to give Traefik a stable IP.
- Egress is open for Charmhub, the Juju OCI registry, and Snapcraft.

### Plan for TLS

Production deployments should use TLS.
See [How to configure TLS encryption](/how-to/deploy-and-manage/configure-tls-encryption) for the available modes and what you need to prepare (for example, an external certificates provider).

### Authentication and authorization
Only the Grafana and Traefik charms support auth.
For exposing Grafana publicly, use two Traefik charms, one for internal connections, and another for external access, which will provide ingress to Grafana.

### Dedicated Juju controller and model

You should bootstrap a dedicated Juju controller and model just for COS.
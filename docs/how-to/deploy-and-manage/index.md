---
myst:
  html_meta:
    description: "Practical how-to guides for deploying, upgrading, and managing different components of COS."
---

(deploy-and-manage)=

# Deploy and manage

These guides cover deploying, upgrading, managing, and securing access to COS.

## Deploy

See our [tutorials](/tutorial/index) for guidance on deploying COS.

```{toctree}
:maxdepth: 1

Install <install>
Configure strict reproducibility <configure-strict-reproducibility>
Configure the Juju model <configure-juju-model>
Configure the Grafana database <configure-grafana-database>
Deploy Mimir on Juju <deploy-mimir-on-juju>
```

## Secure access

Protect and expose COS endpoints for production traffic.

```{toctree}
:maxdepth: 1

Configure TLS encryption <configure-tls-encryption>
Configure ingress <configure-granular-ingress>
```

## Upgrades

Move between COS revisions with confidence.

```{toctree}
:maxdepth: 1

Cross-track upgrade instructions <upgrade>
```


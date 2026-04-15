---
myst:
 html_meta:
   description: "Configure ingress in COS and COS Lite - for external access to Observability Stack components using Traefik as the ingress controller."
---

# How to configure granular ingress in COS

```{Note}
This feature is not available in track/2, only later versions have this ability
```

Both COS and COS Lite allow you to configure Traefik ingress for certain internal components. This configuration determines which applications are integrated with Traefik via an ingress interface; routing their traffic through Traefik.

```{mermaid}
%%{init: { "theme": "dark" } }%%
flowchart LR
  user([External traffic])

  subgraph COS [cos-model]
    traefik[traefik]
    grafana[grafana]
    alertmanager[alertmanager]
    catalogue[catalogue]
    loki[loki]
    prometheus[prometheus]
  end

  user --> traefik
  traefik -->|"ingress = true"| grafana
  traefik -. "ingress = false" .-> alertmanager
  traefik -. "ingress = false" .-> catalogue
  traefik -. "ingress = false" .-> loki
  traefik -. "ingress = false" .-> prometheus

  classDef Charm stroke:white,stroke-width:1px,color:white,rx:8px,ry:8px
  classDef Disabled stroke:#666,stroke-width:1px,color:#aaa,rx:8px,ry:8px
  class traefik,grafana,user Charm
  class alertmanager,catalogue,loki,prometheus Disabled
```

## Configure the Terraform module

```{Note}
If you are using COS Lite, create a cos-lite module with the cos-lite source: [`git::https://github.com/canonical/observability-stack//terraform/cos-lite`](https://github.com/canonical/observability-stack/tree/main/terraform/cos-lite).

The [COS Lite bundle](https://charmhub.io/cos-lite) is now deprecated in favor of Terraform modules.
```

Using the following Terraform module, set your ingress options to enable or disable routing traffic through Traefik.

```{literalinclude} /how-to/install-and-upgrade/cos-ingress.tf
```

Ensure that you have provided any required variables (update the `... other inputs ...` placeholder) for the respective COS module before applying the configuration, by running `terraform apply`.

---
myst:
 html_meta:
   description: "Enable ingress in COS and COS Lite - configure external access to Observability Stack components using Traefik as the ingress controller."
---

# Traefik ingress in COS

Both COS and COS Lite, have the ability to toggle Traefik ingress for some of their internal components.

```{Note}
This feature is not available in track/2, only later versions have this ability
```

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

Using the following Terraform root module, you can control `ingress`:

```{Note}
If you are using COS Lite, create a cos-lite module with the cos-lite source: [`git::https://github.com/canonical/observability-stack//terraform/cos-lite`](https://github.com/canonical/observability-stack/tree/main/terraform/cos-lite).

The [COS Lite bundle](https://charmhub.io/cos-lite) is now deprecated in favor of Terraform modules.
```

```{literalinclude} /how-to/install-and-upgrade/cos-ingress.tf
```

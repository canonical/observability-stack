# TLS encryption in COS

For both COS and COS Lite, the following statements detail the default TLS implementation:

- COS charms generate CSRs with the K8s FQDN as the SAN DNS and the internal CA signs.
- All COS charms trust the internal CA by installing the CA certificate in the charm and workload containers, using the `update-ca-certificates` tool.
- The external CA provides a certificate for Traefik's external URL.
- Within the COS model, workloads communicate via K8s FQDN URLs.
- Requests coming from outside of the model, use the ingress URLs.
- Traefik is able to establish a secure connection with its proxied apps thanks to trusting the local CA.

```{note}
If you have other certificate requirements, you'll be able to replace the self-signed-certificates operator with another TLS operator of your liking, consulting the "Providing" section of [the `tls-certificates` interface page on Charmhub](https://charmhub.io/integrations/tls-certificates).
```

The end-to-end COS TLS design is described in the diagram below. The diagram is limited to mimir (or prometheus for COS Lite) and alertmanager for brevity and clarity.

```{mermaid}
%%{init: { "theme": "dark" } }%%
flowchart TB
  subgraph COS [cos-model]
    traefik[traefik]
    prometheus[prometheus/mimir]
    alertmanager[alertmanager]
    localca[local-ca]
  end

  subgraph OtherModel [other-model]
    route53[route53-acme-operator]
  end

  subgraph ObserveModel [observable-model]
    grafana[grafana-agent]
  end

  subgraph WWW [WWW]
    le[Let's encrypt]
    route53dns[Amazon Route 53]
  end

  grafana -->|"remote_write<br>(example.com)"| prometheus
  prometheus -->|"self-monitoring<br>(am-0.cluster.local)"| alertmanager
  route53 -->|"tls_certificates<br>(example.com)"| traefik
  traefik -->|"ingress-per-unit<br>(prom-0.cluster.local)"| prometheus
  traefik -->|"ingress-per-app<br>(am-*.cluster.local)"| alertmanager

  prometheus -->|"tls_certificates<br>(prom-0.cluster.local)"| localca
  alertmanager -->|"tls_certificates<br>(am-0.cluster.local)"| localca
  localca -->|"certificate_transfer<br>(local_ca)"| traefik

  route53 -->|"certificate_transfer<br>(external_ca)"| grafana

  le -.-> route53
  route53dns -.-> route53

  classDef ExternalNode fill:black,stroke:white,stroke-width:1px,color:white,rx:8px,ry:8px
  class le,route53dns ExternalNode
  style WWW fill:grey,stroke:white,stroke-width:1px,rx:8px,ry:8px
```

As with any TLS configuration, keep in mind best practices such as frequent certificate rotation.  See [this guide](https://charmhub.io/blackbox-exporter-k8s/docs/monitor-ssl-certificates) for an example of monitoring certificates.

```{warning} currently there is a [known issue](https://github.com/canonical/operator/issues/970) due to which some COS relations are limited to in-cluster relations only.
```

## COS

COS can be deployed end-to-end encrypted, with TLS termination only, or unencrypted.

`````{tab-set}
````{tab-item} End-to-end TLS
:sync: e2e-tls-cos

The following Terraform root module enables internal TLS by setting the `internal_tls` value to `true`. By instantiating the COS module with a `certificates` provider offer URL (from the `ssc` module in this example), Traefik is provided certificates to enable TLS termination. The combination of these settings enables end-to-end TLS.

```{tip}
- `internal_tls` -> `true`
- `external_certificates_offer_url` -> not `null`
```

```{literalinclude} /how-to/cos-tls.tf
```
````

````{tab-item} TLS-terminated
:sync: tls-terminated-cos

To remove the internal TLS configuration, override the COS module's `internal_tls` value to `false`. By instantiating the COS module with a `certificates` provider offer URL (from the `ssc` module in this example), Traefik is provided certificates to enable TLS termination. The combination of these settings enables TLS termination.

```{tip}
- `internal_tls` -> `false`
- `external_certificates_offer_url` -> not `null`
```

```{literalinclude} /how-to/cos-tls.tf
```
````

````{tab-item} Unencrypted
:sync: unencrypted-cos

To remove the internal TLS configuration, override the COS module's `internal_tls` value to `false`. To remove TLS termination, override the COS module's `external_certificates_offer_url` to `null`. The combination of these settings enables unencrypted mode.

```{tip}
- `internal_tls` -> `false`
- `external_certificates_offer_url` -> `null`
```

```{literalinclude} /how-to/cos-tls.tf
```
````
`````

## COS Lite

```{Note}
The [COS Lite bundle](https://charmhub.io/cos-lite) is now deprecated in favor of Terraform modules.
```

COS Lite can be deployed end-to-end encrypted, with TLS termination only, or unencrypted.

`````{tab-set}
````{tab-item} End-to-end TLS
:sync: e2e-tls-cos-lite

The following Terraform root module enables internal TLS by setting the `internal_tls` to `true`. By instantiating the COS Lite module with a `certificates` provider offer URL (from the `ssc` module in this example), Traefik is provided certificates to enable TLS termination. The combination of these settings enables end-to-end TLS.

```{tip}
- `internal_tls` -> `true`
- `external_certificates_offer_url` -> not `null`
```

```{literalinclude} /how-to/cos-lite-tls.tf
```

````

````{tab-item} TLS-terminated
:sync: tls-terminated-cos-lite

To remove the internal TLS configuration, override the COS Lite module's `internal_tls` value to `false`. By instantiating the COS Lite module with a `certificates` provider offer URL (from the `ssc` module in this example), Traefik is provided certificates to enable TLS termination. The combination of these settings enables TLS termination.

```{tip}
- `internal_tls` -> `false`
- `external_certificates_offer_url` -> not `null`
```

```{literalinclude} /how-to/cos-lite-tls.tf
```
````

````{tab-item} Unencrypted
:sync: unencrypted-cos-lite

To remove the internal TLS configuration, override the COS Lite module's `internal_tls` value to `false`. To remove TLS termination, override the COS Lite module's `external_certificates_offer_url` to `null`. The combination of these settings enables unencrypted mode.

```{tip}
- `internal_tls` -> `false`
- `external_certificates_offer_url` -> `null`
```

```{literalinclude} /how-to/cos-lite-tls.tf
```
````
`````

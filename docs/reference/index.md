---
myst:
  html_meta:
    description: "Use this COS reference material for release information, security details, Juju topology, compatibility matrices, and operational best practices."
---

(reference)=

# Reference

These pages include reference material for deploying, operating and integrating with COS.
Use it when you need exact requirements, compatibility matrices, or operational hardening
guidance.

## Release & lifecycle

Information about releases, timelines and our policy for updates and
compatibility.

```{toctree}
:maxdepth: 1

Release Notes <../release-notes>
Release Policy <release-policy>
System Requirements <system-requirements>
```

## Security

Hardware, software and security guidance required for production use. Consult
these pages before planning or hardening a deployment.

```{toctree}
:maxdepth: 1

Security Hardening Guide <security-hardening-guide>
Cryptographic Documentation <cryptographic-documentation>
```

## Topology

Topology reference pages describing how COS makes us of Juju topology as telemetry labels.

```{toctree}
:maxdepth: 1

Model Topology for COS Lite <../explanation/about-cos/cos-lite-model-topology>
Juju Topology Labels <../explanation/about-cos/juju-topology-labels>
```

## Integrations & artifacts

Compatibility and packaging information for charms, snaps, and rocks (OCI images).

```{toctree}
:maxdepth: 1

Integration Matrix <integration-matrix>
COS components <cos-components>
```

## Deployment best practices

Operational guidance and recommended patterns for deploying and managing
COS in production.

```{toctree}
:maxdepth: 1

Deployment Best Practices <best-practices/index>
```

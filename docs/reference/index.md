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

## Integrations & artifacts

Compatibility and packaging information for charms, snaps, and rocks (OCI images).

```{toctree}
:maxdepth: 1

Integration Matrix <integration-matrix>
COS components <cos-components>
```

## Architecture decisions

Choose the right model topology and network layout for your deployment scale
and security requirements.

```{toctree}
:maxdepth: 1

Topology <topology>
Networking <networking>
```

## Day-2 operations

Plan for upgrades, data retention, and storage sizing to keep COS healthy
over time.

```{toctree}
:maxdepth: 1

Lifecycle <lifecycle>
Storage <storage>
```

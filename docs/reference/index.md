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

## Sizing & capacity

Plan compute and storage resources for your deployment scale and retention
requirements.

```{toctree}
:maxdepth: 1

Sizing guide <system-requirements>
Storage <storage>
```

## Release & lifecycle

Information about releases, timelines and our policy for updates and
compatibility.

```{toctree}
:maxdepth: 1

Release policy <release-policy>
```

## Security

Hardware, software and security guidance required for production use. Consult
these pages before planning or hardening a deployment.

```{toctree}
:maxdepth: 1

Security hardening guide <security-hardening-guide>
Cryptographic documentation <cryptographic-documentation>
```

## Integrations & artifacts

Compatibility and packaging information for charms, snaps, and rocks (OCI images).

```{toctree}
:maxdepth: 1

Integration matrix <integration-matrix>
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

Plan for upgrades and data retention to keep COS healthy
over time.

```{toctree}
:maxdepth: 1

Lifecycle <lifecycle>
```

## Coordinated workers roles & meta-roles

Roles and meta-roles used in the coordinated workers.

```{toctree}
:maxdepth: 1

Coordinated workers roles & meta-roles <coordinated-workers-meta-roles>
 ```
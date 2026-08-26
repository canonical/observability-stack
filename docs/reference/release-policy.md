---
myst:
 html_meta:
  description: "Understand the COS release policy, including LTS and short-term releases, cadence expectations, and support windows for planning upgrades."
---

# Release policy

Our release policy includes two kinds of releases, short-term releases and long-term support (LTS) releases.

We release every six months, same as Ubuntu, and our LTS releases coincide with [Ubuntu's LTS release cadence](https://ubuntu.com/about/release-cycle).

## A note on terminology

Throughout this page we talk about **product releases**: COS (and COS Lite) `1`, `2`, `3.0`, and so on. A product release pins a specific combination of charm revisions and Terraform module versions that we test and support together.

"Track" is a Charmhub concept, and each component charm is versioned independently on Charmhub: Grafana, Loki, Mimir, and the others all have their own tracks that rarely line up with the product release number. Some charms happen to use `3.0` as their track for COS 3.0, but most do not. See the [release notes](../release-notes.md) for the exact charm tracks bundled in a given product release.

You may also encounter phrases like "track 3 charms" or "track 3.0 charms" used informally to mean "charms released as part of COS 3.0", our Ubuntu 26.04-based LTS release. This is a shorthand for the product release, not a reference to any specific Charmhub track.

Correspondingly, `track/3.0` in this documentation repository is a **git branch** that hosts the docs for the COS 3.0 product release, not a Charmhub track.


## Releases

Short-term releases receive security patches and critical bug fixes for nine months. LTS releases receive standard support for the same window as the Ubuntu base they are built on (see [Ubuntu's release cycle](https://ubuntu.com/about/release-cycle)), and extended support with an [Ubuntu Pro](https://ubuntu.com/pro) subscription.

| Release                                                                                | LTS | Cycle | Base         | Release date  | Standard support  | Extended support |
| -------------------------------------------------------------------------------------- | --- | ----- | ------------ | ------------- | ----------------- | ---------------- |
| [`3.0`](https://documentation.ubuntu.com/observability/track-3.0/release-notes/)       | Yes | 26.04 | Ubuntu 26.04 | July 2026     | May 2031          | May 2041         |
| [`2`](https://documentation.ubuntu.com/observability/track-2/reference/release-notes/) | No  | 25.10 | Ubuntu 24.04 | November 2025 | July 2026         |                  |
| `1`                                                                                    | No  | 25.04 | Ubuntu 24.04 | May 2025      | February 2026     |                  |


## Peripheral charms

[Peripheral charms](../explanation/architecture/peripheral-charms/index), such as Blackbox Exporter, are not bundled in COS or COS Lite, but they follow the same release policy: LTS peripheral charms are supported for the same window as the LTS product release they align with, and short-term peripheral charms follow the nine-month window.

Because peripheral charms are consumed on their own (not through the COS or COS Lite Terraform module), they do not carry a product release number. To pick the right revision, refer to each charm's Charmhub page for its supported tracks and to the [release notes](../release-notes.md) of the product release you are aligning against for the recommended revision.


## Charmhub tracks and git branches
Charmhub tracks (per charm) are created at the beginning of a cycle; the corresponding git branch is created at the end of a cycle.

For example, during June-September 2025 the charms that make up COS 2 already had their `2`-series tracks on Charmhub, but this documentation repository still only had `track/1` and `main` branches on GitHub.

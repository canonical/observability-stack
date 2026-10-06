# AGENTS.md

Guidance for AI agents working in this repository. See
[README.md](README.md) and [DEVELOPERS.md](DEVELOPERS.md) for the project itself.

## COS components reference

`docs/reference/cos-components/index.md` documents a single product release,
named in its opening line ("the current **Observability 3.1** release"). Every
track on the page belongs to that release.

`canonical/observability`'s `manifest.yaml` is the source of truth for:

- the `Track` and `LTS` columns of the charm tables
- which charms a product bundles (`products[].releases[].components`)
- the rocks and snaps tables, and each component's repository links

Join a Charmhub slug to a manifest component key through the page's own
**Terraform variable mapping** table. The names rarely line up: `ssc` is
`self-signed-certificates`, `s3_integrator` is `s3-integrator`, and `loki`,
`mimir` and `tempo` each cover a coordinator and a worker.

Hand-maintained, because the manifest does not carry them:

- `Substrate`.
- `Workload version`, which is not the track: the coordinator charms ship an
  nginx workload (`1.27`) on a different track from the charm itself.

Some charms are deployed only when an input asks for them — Traefik needs
`ingress` set, `ssc` needs `internal_tls` false. The tables do not say so, and
`terraform/*/applications.tf` holds the `count` that decides it. When adding a
row, check whether the module gates it.

`just cut-release` freezes `terraform/*/locals.tf` and leaves the docs alone.
After cutting a release, update the page on the release branch: the release in
the opening line, and the `Track` and `LTS` columns for whatever moved.